//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 03.02.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Private Properties
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteIOS
        label.font = .systemFont(ofSize: Constants.textMaxSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGrayIOS
        label.font = .systemFont(ofSize: Constants.textMinSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteIOS
        label.font = .systemFont(ofSize: Constants.textMinSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let profileName = "Екатерина"
    private let profileSurname = "Новикова"
    private let profileLogin = "@ekaterina_nov"
    private let profileDescription = "Hello, World!"
    
    private let profileImage = UIImage(resource: .avatar)
    private let profileLogoutImage = UIImage(systemName: "person.crop.circle.fill")
    
    private enum Constants {
        static let profileImageSize: CGFloat = 70
        static let logoutImageSize: CGFloat = 44
        
        static let textMinSize: CGFloat = 13
        static let textMiddleSize: CGFloat = 17
        static let textMaxSize: CGFloat = 23
        
        static let headerHorizontalInset: CGFloat = 16
        static let headerTopInset: CGFloat = 32
        static let lineSpacing: CGFloat = 8
    }
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let view else { return }
        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
    }
    // MARK: - IB Actions
    @IBAction private func didTapLogoutButton() {
        avatarImageView.image = profileLogoutImage
        avatarImageView.tintColor = .gray
        nameLabel.removeFromSuperview()
        loginNameLabel.removeFromSuperview()
        descriptionLabel.removeFromSuperview()
    }
    // MARK: Private Methods
    private func setupViews() {
        avatarImageView.image = profileImage
        view.addSubview(avatarImageView)
        
        nameLabel.text = makeFullName()
        view.addSubview(nameLabel)
        
        loginNameLabel.text = profileLogin
        view.addSubview(loginNameLabel)
        
        descriptionLabel.text = profileDescription
        view.addSubview(descriptionLabel)
        
        logoutButton.setImage(.logout, for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.profileImageSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.profileImageSize),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                 constant: Constants.headerTopInset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: Constants.headerHorizontalInset),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor,
                                           constant: Constants.lineSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                                constant: Constants.lineSpacing),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor,
                                                  constant: Constants.lineSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.logoutImageSize),
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.logoutImageSize),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                   constant: -Constants.headerHorizontalInset)
        ])
    }
    private func makeFullName() -> String {
        profileName + " " + profileSurname
    }
}
