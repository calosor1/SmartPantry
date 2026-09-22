//
//  RecipeViewModel.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-15.
//

import Foundation

@MainActor
class RecipeViewModel: ObservableObject {
    
    @Published var recipes: [SavedRecipe] = []
    
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let recipeService = RecipeService()
    
    func saveRecipe(_ recipe: Recipe) async {
        guard let token = KeychainManager.getToken() else {
            errorMessage = "Utilisateur non connecté."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await recipeService.saveRecipe(recipe: recipe, token: token)
            recipes = try await recipeService.fetchRecipes(token: token) //refresh
        } catch {
            errorMessage = "Erreur: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchRecipes() async {
        guard let token = KeychainManager.getToken() else {
            errorMessage = "Utilisateur non connecté."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            recipes = try await recipeService.fetchRecipes(token: token)
        } catch {
            errorMessage = "Erreur: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteRecipe(id: String) async {
        guard let token = KeychainManager.getToken() else {
            errorMessage = "Utilisateur non connecté."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await recipeService.deleteRecipe(id: id, token: token)
            recipes.removeAll { $0.id == id }
            //on va delete la recette comme ça donc sans recall l'api
        } catch {
            errorMessage = "Erreur: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
