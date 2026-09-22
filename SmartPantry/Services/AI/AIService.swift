//
//  AIService.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-11.
//

import Foundation

//ref OpenAI: https://developers.openai.com/api/docs/guides/structured-outputs?lang=javascript
//ref schéma JSON: https://json-schema.org/learn/getting-started-step-by-step

class AIService {
    
    private let baseURL = "https://hapi.cegeplabs.qc.ca/smartpantry"
    
    private let prompt = "Tu es un chef cuisinier. Génère une recette à partir des ingrédients fournis."
    //le prompt qu'on communique à l'IA
    
    private let schemaName = "recipe_result"
    //
    
    private let schema: [String: Any] = [
        "type": "object",
        "properties": [
            "title": ["type": "string"],
            "ingredients": [
                "type": "array",
                "items": ["type": "string"]
            ],
            "steps": [
                "type": "array",
                "items": ["type": "string"]
            ]
        ],
        "required": ["title", "ingredients", "steps"]
    ]
    //schéma type String pour les keys et Any pour les values puisque nos values peuvent être autant
    //une string simple comme la valeur de type étant égal à objet et la valeur de required
    // étant un tableau de string

    //type = objet pour dire à l'IA on veut que le JSON soit un objet
    //les properties seront les fields attendus du JSON que l'IA va retourner
    //title le type est string
    //ingrédients le type est array
    //ensuite spécifie items (dire chaque item dedans L'array) seront de type string

    //les steps seront de type array aussi et chaque item dedans sera une string
    // donc steps est array de strings
    //l'ia va inscrire les étapes de la recette dedans cet array
    
    func generateRecipe(input: String, token: String) async throws -> Recipe {
        
        guard let url = URL(string: "\(baseURL)/ai") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "input": input,
            "prompt": prompt,
            "schemaName": schemaName,
            "schema": schema
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(Recipe.self, from: data)
        return decoded
    }
}
