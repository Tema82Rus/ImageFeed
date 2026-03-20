//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 04.03.2026.
//

import Foundation

struct UserResult: Codable {
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
    
    var profileImage: ProfileImage
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.profileImage = try container.decode(ProfileImage.self, forKey: .profileImage)
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

final class ProfileImageService {
    // MARK: - Static Properties
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    static let shared = ProfileImageService()

    // MARK: - Private Properties
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    // MARK: - Private Initializers
    private init() {}
    
    // MARK: - Open Methods
    func resetURL() {
        avatarURL = nil
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }

        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let result):
                guard let self else { return }
                self.avatarURL = result.profileImage.small
                completion(.success(result.profileImage.small))
                
            NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                            object: self,
                                            userInfo: ["URL": self.avatarURL ?? ""]
            )
                
            case .failure(let error):
                print("[fetchProfileImageURL]: Ошибка запроса \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }

    // MARK: - Private Methods
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

