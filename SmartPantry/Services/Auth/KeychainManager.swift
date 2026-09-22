//
//  KeychainManager.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-07.
//

import Foundation
import Security

//ref utiles:
//https://www.youtube.com/watch?v=v-TvppbEjmE
//https://www.youtube.com/watch?v=cQjgBIJtMbw
//https://www.youtube.com/watch?v=SGcj7s6FMjM
//https://medium.com/@harshaag99/understanding-keychains-in-swift-df71ef633b68

//keychain est similaire à une base de donnée sécurisée comportant des paires clé-valeur

class KeychainManager {
    
    static func save(token: String) {
        let data = Data(token.utf8)
        // Keychain ne store pas des strings, seulement des raw bytes
        // token.utf8 fait genre la conversion, en retournant une VIEW des bytes du
        // string (mais pas indépendant, lié au string original, donc on peut pas juste passer token.utf8 ailleurs)
        // Data() matérialise cette view en un objet concret qu'on peut passer ailleurs (genre à d'autres APIs)
        // sans Data(), on ne peut pas donner les bytes à Keychain directement
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecValueData as String: data
        ]
        //la query ici sous forme de dictionaire représente l'opération à
        // faire avec les paramètres pour filtrer

        //kSecClass =  quelle "table" aller chercher, genre kSecClassGenericPassword est un des
        //types d.items que peut contenir la keychain

        //kSecAttrAccount = l'identifiant de la row, c'est simplement la clé associée à la valeur qu'on
        //veut aller chercher, c'est nous qui la définie comme on veut comme "authToken"

        //kSecValueData = la valeur qu'on veut store, apparait seulement dans méthode save()

        //les 3 sont cast as String parce que les kSec sont tous des types CFString venant de C-land
        //puisque ces trucs là sont vieux, mais notre dictionnaire est de type [String: Any] donc la partie
        //String à gauche du : représente le type de nos clés en String (qu'on cast puisque à la base les clés utilisées
        //comme kSecClass sont de type CFString)

        //tandis que la partie de droite, le any, représente les types de nos valeurs et pas le choix de mettre
        //any car cela peut être une string comme "authToken", un Data object ou bien un
        // CFString comme kSecClassGenericPassword
        
        SecItemDelete(query as CFDictionary)
        // remove le vieux token si existe, évite erreur de duplicate keys, car keychain ne override pas l'ancien
        //et donc si on tenterait de SecItemAdd() et que la clé authToken existe déjà, on aurait une erreur

        SecItemAdd(query as CFDictionary, nil)
        //certains tutos ferait let status = SecItemAdd(), mais pas besoin d'obtenir le status (OSStatus integer)
        //car on a pas de risque d'erreur ici vu qu'on a déjà éliminé la possibilité d'avoir un
        //duplicate keys error avec la ligne de code juste avant

        //nil en deuxième paramètre, sinon serait &result donc une variable passé en
        //référence qu'on aurait instancié juste avant

        //le &result serait une référence à l'item créé dans le keychain
        //comme une row entière qu'on viendrait de créé dans une database, on
        //pourrait donc immédiatement s'en servir et extraire ce qu'on a besoin
        //mais on fait pas ici on veut juste save, donc nil
        
    }
    
    static func getToken() -> String? {
        // retourne String? (optionnel) car 3 choses peuvent échouer:
        // 1. SecItemCopyMatching échoue (status != errSecSuccess)
        // 2. aucun token sauvegardé dans le Keychain (premier lancement, jamais connecté)
        // 3. la conversion des raw bytes vers String échoue (données corrompues)
        // dans tous ces cas on retourne nil plutôt que de crasher

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword, //la table ou type de données qu'on recherche
            kSecAttrAccount as String: "authToken", //l'identifiant de la row qu'on veut
            kSecReturnData as String: true,
            //confirme qu'on veut bien obtenir la valeur (en raw bytes pour l'Instant)
            //si avait pas cette ligne avec valeur true, rien serait écrit dans result (serait nil)
            //et à la place la query retournerait juste une confirmation de si un match est trouvé ou pas
            //et cette confirmation est store dans le let status = genre exemple:
            // status = errSecSuccess veut dire "found it"
            // status = errSecItemNotFound veut dire "nothing there"
            kSecMatchLimit as String: kSecMatchLimitOne //veut juste 1 résultat
        ]
        
        var result: AnyObject?
        //la qu'on store le resultat de la ligne de code en-dessous
        //on passe en référence result dedans SecItemCopyMatching car cette méthode est design comme cela
        //tu lui passe la query, le select se fait pour trouver le match selon les paramètres de la query qu'on
        //a défini en haut et ensuite SecItemCopyMatching écrit le résultat directement au pointeur qu'on
        //a donné (le &result)

        //doit typer result as AnyObject car c'est requis dans la signature de SecItemCopyMatching()
        
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        //en plus d'écrire le résultat dedans le result qu'on a passé en référence, caller la fonction de
        //SecItemCopyMatching retourne un status (OSStatus integer) qu'on peut ensuite faire de la validation
        
        //// les 3 conditions ici correspondent aux 3 cas d'échec documentés en haut
        if status == errSecSuccess, //condition 1: si status est un succès (cas échecs 1 et 2)
            let data = result as? Data,
            // condition 2: as? car le cast pourrait échouer (result pourrait être nil)
            // si échoue, retourne nil au lieu de crasher (safe cast)
            // puisque result était de type AnyObject, doit cast en Data pour ensuite être en mesure
            // de créer une string avec ce Data et le encoding .utf8
            //car la signature de String() requière que le premier paramètre soit de type Data
            let token = String(data: data, encoding: .utf8) {  //(cas échec 3)
            //condition 3: si réussi à converti le Data en String
            return token //return le token en String
        }
        
        return nil
        //si conditions ont fail on va juste return nil, d'où le String? comme valeur de retour
        //dedans la signature de la fonction
    }
    
    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword, //la table qu'on veut
            kSecAttrAccount as String: "authToken" //la row qu'on veut
        ]
        // pas besoin de kSecReturnData ou kSecMatchLimit
        // on veut juste identifier et supprimer la row, pas besoin de récupérer la valeur
        
        SecItemDelete(query as CFDictionary) //effectue le delete
    }
}
