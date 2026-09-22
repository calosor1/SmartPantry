//
//  Recipe.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-12.
//

struct Recipe: Codable {
    let title: String
    let ingredients: [String]
    let steps: [String]
}
