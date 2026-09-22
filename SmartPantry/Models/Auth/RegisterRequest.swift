//
//  MeResponse.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-06.
//

import Foundation

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let name: String
}
