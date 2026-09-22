//
//  VisionViewModel.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-07.
//

import SwiftUI

@MainActor
class VisionViewModel: ObservableObject {
    
    @Published var selectedImage: UIImage?
    @Published var extractedText = ""
    
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let visionService = VisionService()
    
    func extractText() async {
        guard let image = selectedImage else {
            errorMessage = "Aucune image sélectionnée."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            extractedText = try await visionService.extractText(from: image)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
