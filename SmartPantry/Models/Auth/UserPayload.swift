//
//  MeResponse.swift
//  SmartPantry
//
//  Created by Alexandre on 2026-04-06.
//

import Foundation

struct UserPayload: Decodable {
    let id: String
    let email: String
    let name: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case createdAt = "created_at"
    }
}
