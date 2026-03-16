//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 27.02.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    private var imageView: UIImageView!
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupImage()
        
        if storage.token != nil {
            guard let token = storage.token else { return }
            fetchProfile(token: token)
        } else {
            setupAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case let .success(profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                break
            }
        }
    }
    
    func setupImage() {
        let imageSplashLogo = UIImage(resource: .vector)
        
        imageView = UIImageView(image: imageSplashLogo)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setupAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
}
// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else { return }
        
        fetchProfile(token: token)
        //switchToTabBarController()
    }
}

