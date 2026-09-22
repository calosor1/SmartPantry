//
//  LoginView.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-06.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: AuthViewModel
    @State private var showRegister = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 60))
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text("SmartPantry")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Cuisine intelligente, zéro gaspillage")
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Connexion")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                SecureField("Mot de passe", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Se connecter")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.mint)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(viewModel.isLoading)
                
                HStack(spacing: 4) {
                    Text("Pas de compte?")
                        .foregroundColor(.gray)
                    
                    Button("Inscription") {
                        showRegister = true
                    }
                    .foregroundColor(.mint)
                    .fontWeight(.semibold)
                }
                .font(.footnote)
                
                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color.mint.opacity(0.15))
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView()
        }
        //full screen feel plus naturel que sheet dans ce cas-ci
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
