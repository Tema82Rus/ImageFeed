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
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case likedByUser = "liked_by_user"
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
        
        guard let token = OAuth2TokenStorage.shared.token?.data else { return }
        
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self else { return }
            defer { self.task = nil }
            guard let data, error == nil else { return }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                
                let newPhotos = photoResults.map { result -> Photo in
                    let date = result.createdAt.flatMap { self.dateFormatter.date(from: $0) }
                    return Photo(id: result.id,
                                 size: CGSize(width: result.width, height: result.height),
                                 createdAt: date,
                                 welcomeDescription: result.description,
                                 thumbImageURL: result.urls.small, largeImageURL: result.urls.full,
                                 isLiked: result.likedByUser
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
}
