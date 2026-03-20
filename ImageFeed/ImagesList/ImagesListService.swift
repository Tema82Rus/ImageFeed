//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 18.03.2026.
//

import Foundation
internal import CoreGraphics

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let welcomeDescription: String?
    let isLiked: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
        case urls
    }
    
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

enum UnsplashError: Error {
    case invalidURL
    case invalidToken
    case invalidResponse
}


final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImageListServiceDidChange")
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    private var task: URLSessionTask?
    private var perPage = 10
    private let urlSession = URLSession.shared
    private let dateFormatter = ISO8601DateFormatter()
    
    
    private init() {}
    
    func fetchPhotosNextPage() {
        if task != nil { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Token не получен")
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        //        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self else { return }
            defer { self.task = nil }
            
            if let error {
                print("Network error: \(error.localizedDescription)")
            }
            
            
            guard let data else { return }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                print("Success: \(photoResults)")
                
                let newPhotos = photoResults.map { result -> Photo in
                    let date = result.createdAt.flatMap { self.dateFormatter.date(from: $0) }
                    return Photo(id: result.id,
                                 size: CGSize(width: result.width, height: result.height),
                                 createdAt: date,
                                 welcomeDescription: result.welcomeDescription,
                                 thumbImageURL: result.urls.small, largeImageURL: result.urls.full,
                                 isLiked: result.isLiked
                    )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            } catch {
                print("Ошибка декодирования JSON: \(error)")
            }
        }
        task?.resume()
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(UnsplashError.invalidToken))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(UnsplashError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self else { return }
            
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  200..<300 ~= response.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(UnsplashError.invalidResponse))
                }
                return
            }
            
            DispatchQueue.main.async {
                self.updatePhotoLike(photoId: photoId, isLiked: isLike)
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    private func updatePhotoLike(photoId: String, isLiked: Bool) {
        guard let index = photos.firstIndex(where: { $0.id == photoId }) else { return }
        
        let photo = photos[index]
        
        photos[index] = Photo(id: photo.id,
                              size: photo.size,
                              createdAt: photo.createdAt,
                              welcomeDescription: photo.welcomeDescription,
                              thumbImageURL: photo.thumbImageURL,
                              largeImageURL: photo.largeImageURL,
                              isLiked: isLiked
        )
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
    }
}
