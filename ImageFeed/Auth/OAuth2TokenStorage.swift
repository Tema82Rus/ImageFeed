//
//  Untitled.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 26.02.2026.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    // MARK: - Public Properties
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue  {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    // MARK: - Static Properties
    static let shared = OAuth2TokenStorage()
    // MARK: - Private Properties
    private let tokenKey = "OAuth2BearerToken"
    // MARK: - Initializers
    private init() {}
    // MARK: - Public Methods
    func removeToken() {
        token = nil
    }
}
