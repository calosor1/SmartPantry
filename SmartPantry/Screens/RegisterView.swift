//
//  RegisterView.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-06.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
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
                Text("Inscription")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                TextField("Nom", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                SecureField("Mot de passe", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    Task {
                        await viewModel.register()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("S'inscrire")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.mint)
                .foregroundColor(.white)
                .bold()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(viewModel.isLoading)
                
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
        .background(Color(.systemMint).opacity(0.15))
        .onChange(of: viewModel.didRegisterSuccessfully) {
            if viewModel.didRegisterSuccessfully {
                dismiss()
            }
        }
    }
}

#Preview {
    RegisterView()
}
