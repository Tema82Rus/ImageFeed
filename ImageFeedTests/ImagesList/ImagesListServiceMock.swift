//
//  ImagesListServiceSpy.swift
//  ImageFeedTests
//
//  Created by Artem Yaroshenko on 24.03.2026.
//

import Foundation
@testable import ImageFeed

class ImagesListServiceMock: ImagesListService {
    var mockPhotos: [Photo] = []
    var fetchPhotosNextPageCall = false
    var changeLikeCalled = false
    
    override func fetchPhotosNextPage() {
        fetchPhotosNextPageCall = true
    }
    
    override func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}
