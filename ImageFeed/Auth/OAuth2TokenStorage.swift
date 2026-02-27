//
//  Untitled.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 26.02.2026.
//

import Foundation

final class OAuth2TokenStorage {
    // MARK: - Public Properties
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue  {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    // MARK: - Static Properties
    static let shared = OAuth2TokenStorage()
    // MARK: - Private Properties
    private let tokenKey = "OAuth2BearerToken"
    // MARK: - Initializers
    private init() {}
}
