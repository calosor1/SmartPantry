//
//  SavedRecipeDetailView.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-15.
//

import SwiftUI

struct SavedRecipeDetailView: View {
    
    let savedRecipe: SavedRecipe
    
    private let speechService = SpeechService()
    
    var body: some View {
        VStack(spacing: 0) {
            
            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text(savedRecipe.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Ingrédients")
                            .font(.headline)
                        
                        ForEach(savedRecipe.data.ingredients, id: \.self) { ingredient in
                            Text("• \(ingredient)")
                        }
                        
                        Text("Étapes")
                            .font(.headline)
                            .padding(.top, 4)
                        
                        ForEach(Array(savedRecipe.data.steps.enumerated()), id: \.offset) { index, step in
                            Text("\(index + 1). \(step)")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 30)
                    .padding(.top)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Contrôle vocal
            VStack(spacing: 12) {
                
                Button {
                    speechService.speakRecipe(savedRecipe.data)
                } label: {
                    Text("Lire la recette")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Button {
                    speechService.pauseOrResume()
                } label: {
                    Text("Pause / Reprendre")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
            }
            .padding()
        }
        .background(Color.mint.opacity(0.15))
        .navigationTitle("Détails de la recette")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SavedRecipeDetailView(
        savedRecipe: SavedRecipe(
            id: "1",
            title: "Pâtes sauce tomate",
            data: Recipe(
                title: "Pâtes sauce tomate",
                ingredients: ["Pâtes", "Sauce tomate", "Sel"],
                steps: ["Faire bouillir l'eau", "Cuire les pâtes", "Ajouter la sauce"]
            )
        )
    )
}
