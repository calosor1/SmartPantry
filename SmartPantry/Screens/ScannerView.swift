import SwiftUI
import PhotosUI

struct ScannerView: View {
    
    @StateObject private var viewModel = VisionViewModel()
    @StateObject private var aiViewModel = AIViewModel()
    
    @ObservedObject var recipeViewModel: RecipeViewModel
    
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var showRecipeSheet = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                Text("Scanner intelligent")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 220)
                        .overlay(
                            Text("Aucune image sélectionnée")
                                .foregroundColor(.gray)
                        )
                        .padding(.horizontal)
                }
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Choisir une image")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                
                Button {
                    Task {
                        await viewModel.extractText()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Extraire le texte")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.mint)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .disabled(viewModel.selectedImage == nil || viewModel.isLoading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Texte extrait")
                        .font(.headline)
                    
                    TextEditor(text: $viewModel.extractedText)
                        .frame(height: 180)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.4))
                        )
                }
                .padding(.horizontal)
                
                Button {
                    Task {
                        await aiViewModel.generateRecipe(from: viewModel.extractedText)
                    }
                } label: {
                    if aiViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Générer la recette")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .disabled(viewModel.extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiViewModel.isLoading)
                
                Spacer()
            }
            .padding(.top)
        }
        .background(Color.mint.opacity(0.15))
        .alert("Erreur", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: selectedItem) {
            guard let selectedItem else { return }
            
            Task {
                do {
                    if let data = try await selectedItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        viewModel.selectedImage = uiImage
                        viewModel.extractedText = ""
                        aiViewModel.generatedRecipe = nil
                    }
                } catch {
                    viewModel.errorMessage = "Erreur lors du chargement de l'image."
                }
            }
        }
        //Essentiellement, quand scan une nouvelle image, un objet de type PhotosPickerItem
        //qu'on doit utiliser pour le PhotosPicker, ne donne pas une image directe,
        //mais plutôt une référence à l'image dans la librairie.
        //on doit load le data de cette image donc :
        // try await selectedItem.loadTransferable(type: Data.self)
        //on veut le type Data donc Data.self.
        //une fois qu'on a les raw bytes (data) on peut créer notre UIImage
        
        .onChange(of: viewModel.errorMessage) {
            if !viewModel.errorMessage.isEmpty {
                alertMessage = viewModel.errorMessage
                showAlert = true
                viewModel.errorMessage = "" //reset après avoir show le alert
            }
        }
        .onChange(of: aiViewModel.errorMessage) {
            if !aiViewModel.errorMessage.isEmpty {
                alertMessage = aiViewModel.errorMessage
                showAlert = true
                aiViewModel.errorMessage = ""
            }
        }
        
        .onChange(of: aiViewModel.generatedRecipe != nil) {
            if aiViewModel.generatedRecipe != nil {
                showRecipeSheet = true
            }
        }
        
        .sheet(isPresented: $showRecipeSheet) {
            if let recipe = aiViewModel.generatedRecipe {
                GeneratedRecipeView(recipe: recipe, recipeViewModel: recipeViewModel)
            }
        }
    }
}

#Preview {
    ScannerView(recipeViewModel: RecipeViewModel())
}
