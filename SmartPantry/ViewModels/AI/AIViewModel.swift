//
//  AIViewModel.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-12.
//

import Foundation

@MainActor
class AIViewModel: ObservableObject {
    
    @Published var generatedRecipe: Recipe?
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let aiService = AIService()
    
    func generateRecipe(from input: String) async {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedInput.isEmpty {
            errorMessage = "Aucun texte à envoyer à l'IA."
            return
        }
        
        guard let token = KeychainManager.getToken() else {
            errorMessage = "Utilisateur non connecté."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let recipe = try await aiService.generateRecipe(input: trimmedInput, token: token)
            generatedRecipe = recipe
        } catch {
            errorMessage = "Erreur: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
