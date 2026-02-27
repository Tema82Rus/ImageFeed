//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 26.02.2026.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
