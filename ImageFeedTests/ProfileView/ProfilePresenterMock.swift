//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Artem Yaroshenko on 24.03.2026.
//

import Foundation
import ImageFeed

final class ProfilePresenterMock: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var logoutButtonTappedCalled = false
    var updateAvatarCalled = false
    var updateProfileDetailsCalled = false
    var lastProfile: Profile?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        logoutButtonTappedCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func updateProfileDetails(with profile: Profile) {
        updateProfileDetailsCalled = true
        lastProfile = profile
    }
    
}
