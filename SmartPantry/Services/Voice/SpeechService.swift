//
//  SpeechService.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-15.
//

// doc Apple : https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer
// tutoriel : https://www.youtube.com/watch?v=Nuu4-iDJdnQ
// https://www.hackingwithswift.com/example-code/media/how-to-convert-text-to-speech-using-avspeechsynthesizer-avspeechutterance-and-avspeechsynthesisvoice
// https://medium.com/@harshaag99/understanding-avspeechsynthesizer-in-swift-263c61875602

import Foundation
import AVFoundation

class SpeechService {

    private let synthesizer = AVSpeechSynthesizer()

    // paramètres configurés ici
    private let voice      = AVSpeechSynthesisVoice(language: "fr-CA")
    private let speechRate : Float = 0.5
    private let itemDelay  : TimeInterval = 0.4
    //délai entre chaque item exemple chaque ingrédient ou genre entre titre et ingrédients
    //utterance.rate nécessite un Float pas juste double : https://developer.apple.com/documentation/avfaudio/avspeechutterance/rate
    //doit donc le spécifier vu sinon infère le type de 0.5 comme double et peut pas cast double en float car float plus petit
    //utterance.postUtteranceDelay lui veut un TimeInterval : https://developer.apple.com/documentation/avfaudio/avspeechutterance/postutterancedelay

    func speakRecipe(_ recipe: Recipe) {
        stopSpeaking()

        enqueue("Recette. \(recipe.title).")
        enqueue("Ingrédients.")

        for ingredient in recipe.ingredients {
            enqueue(ingredient)
        }

        enqueue("Étapes.")

        for (index, step) in recipe.steps.enumerated() {
            let cleanStep = step.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalStep = cleanStep.hasSuffix(".") ? cleanStep : cleanStep + "."
            enqueue("Étape \(index + 1). \(finalStep)")
        }
        // s'assurer que le step généré par IA finit par un point pour que le synthesizer prenne une pause naturelle
        // ref : https://stackoverflow.com/questions/32967445/how-to-check-what-a-string-starts-with-prefix-or-ends-with-suffix-in-swift
    }

    func pauseOrResume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        } else if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word) //pause au bon mot et peut reprendre
        }
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func enqueue(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice              = voice
        utterance.rate               = speechRate
        utterance.postUtteranceDelay = itemDelay
        synthesizer.speak(utterance)
    }
    //fonction pour lire chaque bout
}
