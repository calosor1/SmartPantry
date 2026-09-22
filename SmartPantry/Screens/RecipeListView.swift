//
//  RecipeListView.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-15.
//

import SwiftUI

struct RecipeListView: View {
    
    @StateObject private var recipeViewModel = RecipeViewModel()
    @State private var showScannerSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                VStack(spacing: 8) {
                    Text("Mes recettes\nsauvegardées")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Retrouvez vos recettes enregistrées")
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recettes")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if recipeViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if recipeViewModel.recipes.isEmpty {
                        Text("Aucune recette sauvegardée.")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(recipeViewModel.recipes) { savedRecipe in
                                    NavigationLink {
                                        SavedRecipeDetailView(savedRecipe: savedRecipe)
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "book")
                                                .foregroundColor(.mint)
                                            
                                            Text(savedRecipe.title)
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.gray.opacity(0.2))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            Task {
                                                await recipeViewModel.deleteRecipe(id: savedRecipe.id)
                                            }
                                        } label: {
                                            Text("Supprimer")
                                        }
                                    }
                                    //swipeAction ref: https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:)
                                    //jai mis le .trailing pour explicite, mais pas besoin car
                                    //c'est le default
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                    
                    Button {
                        showScannerSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Ajouter une recette")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .background(Color.mint)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.top, 8)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color.mint.opacity(0.15))
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await recipeViewModel.fetchRecipes()
        }
        .sheet(isPresented: $showScannerSheet) {
            ScannerView(recipeViewModel: recipeViewModel)
        }
        .alert("Erreur", isPresented: .constant(!recipeViewModel.errorMessage.isEmpty)) {
            Button("OK", role: .cancel) {
                recipeViewModel.errorMessage = ""
            }
        } message: {
            Text(recipeViewModel.errorMessage)
        }
    }
}

#Preview {
    RecipeListView()
}
