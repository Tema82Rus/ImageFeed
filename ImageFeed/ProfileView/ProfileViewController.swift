//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 03.02.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Property
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!
    
    // MARK: - Action
    @IBAction private func didTapLogoutButton() {
        
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
