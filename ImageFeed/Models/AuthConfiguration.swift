//
//  Constants.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 23.02.2026.
//

import Foundation

enum Constants {
    static let accessKey = "JtSgGa5h61PAN_YklGEpz4Q4komNPd8j_34gczoPo8w"
    static let secretKey = "J_NLFcfJV8Vw0TVsA_Emnjc4XkDXWUp4asEeK6-KtuQ"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURLString: String = "https://api.unsplash.com/"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
    static let profileImageSize: CGFloat = 70
    static let logoutImageSize: CGFloat = 44
    
    static let textMinSize: CGFloat = 13
    static let textMiddleSize: CGFloat = 17
    static let textMaxSize: CGFloat = 23
    
    static let headerHorizontalInset: CGFloat = 16
    static let headerTopInset: CGFloat = 32
    static let lineSpacing: CGFloat = 8
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String
    
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURLString: String, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURLString: Constants.defaultBaseURLString,
                                 authURLString: Constants.unsplashAuthorizeURLString)
    }
}
