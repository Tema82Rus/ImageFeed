//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 24.03.2026.
//

import Foundation

public protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapLogoutButton()
    func updateAvatar()
    func updateProfileDetails(with profile: Profile)
}

class ProfileViewPresenter: ProfileViewPresenterProtocol {
    // MARK: - Public Properties
    weak var view: ProfileViewControllerProtocol?
    // MARK: - Private Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let profileLogoutService: ProfileLogoutService
    
    init(
        profileService: ProfileService = ProfileService.shared,
        profileImageService: ProfileImageService = ProfileImageService.shared,
        profileLogoutService: ProfileLogoutService = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
        setupObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Protocol Methods
    func viewDidLoad() {
        if let profile = profileService.profile {
            updateProfileDetails(with: profile)
        }
        updateAvatar()
    }
    
    func didTapLogoutButton() {
        view?.logoutButtonDidTapAlert()
        profileLogoutService.logout()
        view?.dismissView()
    }
    
    func updateAvatar() {
        guard
            let avatarURLString = profileImageService.avatarURL,
            let avatarURL = URL(string: avatarURLString) else {
            view?.updateAvatar()
            return
        }
        view?.updateAvatar()
    }
    
    func updateProfileDetails(with profile: Profile) {
        view?.updateProfileDetails(with: profile)
    }
    
    private func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
    }
    
    private func removeObservers() {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
            profileImageServiceObserver = nil
        }
    }
}
