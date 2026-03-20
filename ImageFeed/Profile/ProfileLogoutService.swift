//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 20.03.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        OAuth2TokenStorage.shared.removeToken()
        ProfileService.shared.resetProfile()
        ProfileImageService.shared.resetURL()
        ImagesListService.shared.resetPhotos()
        
        cleanCookies { [weak self] in
            guard let self else { return }
            self.switchToSplashScreen()
        }
    }
    
    private func cleanCookies(completion: @escaping () -> Void) {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            let group = DispatchGroup()
            
            records.forEach { record in
                group.enter()
                
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    private func switchToSplashScreen() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}
