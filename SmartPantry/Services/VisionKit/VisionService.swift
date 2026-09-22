//
//  VisionService.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-07.
//

import Foundation
import Vision
import UIKit

//doc apple Vision: https://developer.apple.com/documentation/vision/recognizing-text-in-images
//VNRecognizeTextRequest : https://developer.apple.com/documentation/vision/vnrecognizetextrequest
//le code de la doc est quasiement le service monté déjà au complet, reste juste à le mettre dedans une fonction
//avec siganture appropriée.

class VisionService {
    
    func extractText(from image: UIImage) async throws -> String {
        //les images provenant de la librairie du phone sont de type UIImage
        //quand tout est décodé on return une String

        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }
        //le handler accepte juste des cgImage donc doit faire conversion
        // Vision travaille avec des CGImage (bas niveau, genre raw pixels), pas UIImage (haut niveau)
        // on convertit donc l'image pour que Vision puisse l'analyser
        
        let request = VNRecognizeTextRequest()
        //request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        // crée une requête Vision qui définit comment analyser l'image (Optical Character Recognition, OCR)
        // on configure ici les paramètres de reconnaissance du texte
        //par défaut selon la doc le rcognitionLevel est accurate, mais on pourrait le switch pour fast
        //ici on préfère le default de accurate vu que les layouts de texts sur différents packages de bouffe
        //peuvent rendre la tâche plus complexe, on priorise validité plutôt que de la rapidité.
        //donc .accurate = plus lent mais plus précis (meilleur pour lire du texte réel)
        //usesLanguageCorrection améliore la reconnaissance en corrigeant les mots selon la langue
        //genre Riz basrnati vs Riz basmati
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        // le handler est l'objet responsable d'exécuter la requête Vision sur l'image
        //il prend donc l'image qu'on veut analyser en paramètre quand on le crée.

        // options = paramètres supplémentaires (ex: orientation, metadata) si image vient de caméra
        // ici vide en passant [:] car on n'en a pas besoin, aucune configuration nécessaire
        // je l'ajoute pour documentation future, car je l'ai observé présent dans ce tutoriel:
        //https://www.hackingwithswift.com/example-code/vision/how-to-use-vnrecognizetextrequests-optical-character-recognition-to-detect-text-in-an-image
        //mais était absent de l'exemple dans la documentation officielle
        
        try handler.perform([request])
        //handler exécute la request sur l'image qu'on lui a donné lors de sa création

        //donc request = ce qu'on veut faire
        //handler est l'engine qui run la request avec le .perform
        
        guard let observations = request.results else {
            return ""
        }
        
        // Avant, on devait faire:
        // request.results as? [VNRecognizedTextObservation]
        // car results était vu comme [Any]? avec des VNRequest génériques.
        //
        // Mais ici, request est de type VNRecognizeTextRequest,
        // donc Swift sait déjà que results est [VNRecognizedTextObservation]?.
        //
        // Donc aucun cast nécessaire même si certains exemples dans la doc Apple le montrent.
        
        let extractedText = observations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }
        .joined(separator: "\n")
        // pour chaque observation, on prend le meilleur texte reconnu (topCandidates(1))
        // car chaque observation représente “a piece of text Vision found in the image”
        // Vision ne sait pas toujours le text exact et donne pour CHAQUE observation plusieurs guesses
        //genre n guesses et 1 est le meilleur candidat exemple Candidate 1: "basmati" (confidence: 0.92)
        //donc pogne celui qu'il est le plus confiant pour chaque observation qu'on loop au-travers
        //en faisant le compactMap

        //CompactMap élimine les nils et store nos conversions en string vu qu'on a fait .string
        // dedans la partie observation.topCandidates(1).first?.string
        //peut avoir des observations nil si une des observation a fail, donc compactMap élimine les nils

        //joined combine toutes les Strings du tableau de String que on a stored dedans extractedText
        //(suite au compactMap qu'on a faite)
        // en une seule String séparée par des retours de ligne
        
        return extractedText //return la string
    }
}

enum VisionError: LocalizedError {
    case invalidImage
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Impossible de lire l'image sélectionnée."
        }
    }
}
//petite erreur custom pour que si je throw une erreur j'ai accès à error.localizedDescription
//pour mettre dedans le catch et avoir un message plus descriptif.
