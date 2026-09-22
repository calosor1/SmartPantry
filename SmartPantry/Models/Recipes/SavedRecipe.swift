//
//  SavedRecipe.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-15.
//

import Foundation

struct SavedRecipe: Codable, Identifiable {
    let id: String
    let title: String
    let data: Recipe
}
