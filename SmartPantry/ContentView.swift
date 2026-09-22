//
//  ContentView.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-05.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                RecipeListView()
            } else {
                LoginView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.fetchUser()
        }
    }
}

#Preview {
    ContentView()
}
