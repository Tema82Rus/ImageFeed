//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Artem Yaroshenko on 24.03.2026.
//

import Foundation
import ImageFeed

final class ProfileViewMock: ProfileViewControllerProtocol {
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var lastProfile: Profile?
//    var lastAvatarURL: String?
    var showLogoutAlertCalled = false
    var logoutCompletion: (() -> Void)?
    
    func updateProfileDetails(with profile: ImageFeed.Profile) {
        updateProfileDetailsCalled = true
        lastProfile = profile
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
//        last
    }
    
    func logoutButtonDidTapAlert() {
        showLogoutAlertCalled = true
    }
    
    func dismissView() { }
}
