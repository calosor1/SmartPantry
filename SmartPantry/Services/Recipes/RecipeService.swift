//
//  RecipeService.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-15.
//

import Foundation

class RecipeService {
    
    private let baseURL = "https://hapi.cegeplabs.qc.ca/smartpantry"
    
    func saveRecipe(recipe: Recipe, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/recipes") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestBody = SaveRecipeRequest(
            title: recipe.title,
            data: recipe
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchRecipes(token: String) async throws -> [SavedRecipe] {
        guard let url = URL(string: "\(baseURL)/recipes") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode([SavedRecipe].self, from: data)
        return decoded
    }
    
    func deleteRecipe(id: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/recipes/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
