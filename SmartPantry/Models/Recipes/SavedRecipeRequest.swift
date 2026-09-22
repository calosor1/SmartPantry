//
//  SaveRecipeRequest.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-15.
//

import Foundation

struct SaveRecipeRequest: Encodable {
    let title: String
    let data: Recipe
}
