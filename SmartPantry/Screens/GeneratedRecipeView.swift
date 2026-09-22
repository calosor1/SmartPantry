//
//  GeneratedRecipeView.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-15.
//

import SwiftUI

struct GeneratedRecipeView: View {
    
    let recipe: Recipe
    @ObservedObject var recipeViewModel: RecipeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(recipe.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Ingrédients")
                        .font(.headline)
                    
                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                    }
                    
                    Text("Étapes")
                        .font(.headline)
                        .padding(.top, 4)
                    
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                    }
                    //ref ForEach avec index et élément : https://www.avanderlee.com/swiftui/swiftui-foreach-loop-index/
                    
                    //recipes.steps.enumerated() return une sequence
                    //genre EnumeratedSequence<Array<String>>
                    
                    //ForEach a besoin d'une Collection (ou d'un type conforme à Collection),
                    //mais enumerated() retourne une Sequence (avant Swift 6.2),
                    //donc on doit le convertir en Array pour satisfaire ForEach.
                    //alors on wrap recipe.steps.enumerated() dedans un Array
                    
                    //ensuite on a donc de quoi du genre:
                    //[(0, "Cuire le riz"), (1, "Ajouter légumes")]
                    //donc chaque élément a (offset: Int, element: String)
                    //offset représente l'index donc peut s'en servir comme identifiant unique
                    //avec id: \.offset
                    
                    //ensuite en ordre on a donc index, step in
                    //donc l'index pour numéro d'étape et step pour le texte
                    
                    //info extra: une sequence de enumerated return index et l'élément
                    //similaire è un tableau, mais pas toute d'une shot (sinon trop de
                    //mémoire et reviendrait essentiellement è être un array).
                    //les index et valeurs pour un enumerated sont computed au besoin (lazy)
                    
                    //ref swift a nouvelle version qui permet pas besoin de wrap dedans Array,
                    //mais marche pas sur ma version, a conserver pour le futur :
                    // https://stackoverflow.com/questions/57244713/get-index-in-foreach-in-swiftui
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 30)
                .padding(.top)
            }
            
            VStack(spacing: 12) {
                Button {
                    Task {
                        await recipeViewModel.saveRecipe(recipe)
                        dismiss()
                    }
                } label: {
                    if recipeViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Ajouter au garde-manger")
                            .frame(maxWidth: 250)
                            .padding()
                    }
                }
                .background(Color.mint)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(recipeViewModel.isLoading)
                
                Button("Fermer") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .padding()
        }
        .background(Color.mint.opacity(0.15))
    }
}

#Preview {
    GeneratedRecipeView(
        recipe: Recipe(
            title: "Pâtes sauce tomate",
            ingredients: ["Pâtes", "Sauce tomate", "Sel"],
            steps: ["Faire bouillir l'eau", "Cuire les pâtes", "Ajouter la sauce"]
        ),
        recipeViewModel: RecipeViewModel()
    )
}
