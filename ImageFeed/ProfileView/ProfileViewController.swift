//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 03.02.2026.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(with profile: Profile)
    func updateAvatar()
    func logoutButtonDidTapAlert()
    func dismissView()
}

final class ProfileViewController: UIViewController {
    // MARK: - Private Properties
    private(set) lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private(set) lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteIOS
        label.font = .systemFont(ofSize: Constants.textMaxSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGrayIOS
        label.font = .systemFont(ofSize: Constants.textMinSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteIOS
        label.font = .systemFont(ofSize: Constants.textMinSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "logout button"
        return button
    }()

    private let profileName = "Екатерина"
    private let profileSurname = "Новикова"
    private let profileLogin = "@ekaterina_nov"
    private let profileDescription = "Hello, World!"
    
    private let profileImage = UIImage(resource: .avatar)
    private let profileLogoutImage = UIImage(systemName: "person.crop.circle.fill")
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private(set) var presenter: ProfileViewPresenterProtocol?
    // MARK: - deinit
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let view else { return }
        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
        
        if presenter == nil {
            presenter = ProfileViewPresenter()
            presenter?.view = self
        }
        
        presenter?.viewDidLoad()
    }
    // MARK: - IB Actions
    @IBAction private func didTapLogoutButton() {
        logoutButtonDidTapAlert()
    }
    // MARK: - Public Methods
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    func configure(_ presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    // MARK: - Private Methods
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

extension ProfileViewController: ProfileViewControllerProtocol {
    func updateProfileDetails(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginNameLabel.text = profile.loginName.isEmpty ? "Логин не указан" : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let placeholderImage = UIImage(systemName: "person.circle.fill")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal).withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url,
        placeholder: placeholderImage,
                                    options: [.processor(processor),
                                              .scaleFactor(UIScreen.main.scale),
                                              .cacheOriginalImage,
                                              .forceRefresh
                                    ]) { result in
            switch result {
            case .success(let value):
                print(value.image)
                print(value.cacheType)
                print(value.source)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func logoutButtonDidTapAlert() {
        let alert = UIAlertController(title: "Выход из аккаунта",
                                      message: "Вы уверены, что хотите выйти?",
                                      preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { [weak self] _ in
            self?.presenter?.didTapLogoutButton()
//            ProfileLogoutService.shared.logout()
//            self?.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true)
    }
}
