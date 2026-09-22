//
//  MeResponse.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-06.
//

import Foundation

struct LoginResponse: Decodable {
    let token: String
    let tokenType: String
    let expiresIn: String

    enum CodingKeys: String, CodingKey {
        case token
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
