//
//  AuthViewModel.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-06.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    
    @Published var message = ""
    @Published var isLoading = false
    
    @Published var currentUser: UserPayload?
    @Published var isAuthenticated = false
    
    @Published var didRegisterSuccessfully = false
    
    private let authService = AuthService()
    
    func register() async {
        isLoading = true
        message = ""
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail.isEmpty {
            message = "Le courriel est requis."
            isLoading = false
            return
        }
        
        if !trimmedEmail.contains("@") {
            message = "Courriel invalide."
            isLoading = false
            return
        }
        
        if trimmedPassword.count < 8 {
            message = "Le mot de passe doit contenir au moins 8 caractères."
            isLoading = false
            return
        }
        
        if trimmedName.isEmpty {
            message = "Le nom est requis."
            isLoading = false
            return
        }
        
        let requestBody = RegisterRequest(
            email: trimmedEmail,
            password: trimmedPassword,
            name: trimmedName
        )
        
        do {
            try await authService.register(requestBody: requestBody)
            didRegisterSuccessfully = true
            
        } catch {
            message = "Erreur: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func login() async {
        isLoading = true
        message = ""
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail.isEmpty {
            message = "Le courriel est requis."
            isLoading = false
            return
        }
        
        if !trimmedEmail.contains("@") {
            message = "Courriel invalide."
            isLoading = false
            return
        }
        
        if trimmedPassword.isEmpty {
            message = "Le mot de passe est requis."
            isLoading = false
            return
        }
        
        let requestBody = LoginRequest(
            email: trimmedEmail,
            password: trimmedPassword
        )
        
        do {
            let result = try await authService.login(requestBody: requestBody)
            
            KeychainManager.save(token: result.token)
            
            await fetchUser()
            
        } catch {
            message = "Erreur: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchUser() async {
        guard let token = KeychainManager.getToken() else {
            currentUser = nil
            isAuthenticated = false
            return
        }
        
        isLoading = true
        
        do {
            let result = try await authService.getMe(token: token)
            currentUser = result.user
            isAuthenticated = true
                        
        } catch {
            currentUser = nil
            isAuthenticated = false
            message = "Erreur: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
