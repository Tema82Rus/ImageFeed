//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 26.02.2026.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    // MARK: - Public Properties
    let accessToken: String
    let tokenType: String
    let refreshToken: String
    let scope: String
    let createdAt: Int
    
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
    }
}
