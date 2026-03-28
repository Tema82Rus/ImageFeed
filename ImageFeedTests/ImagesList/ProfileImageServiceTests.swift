//
//  ProfileImageServiceTests.swift
//  ImageFeedTests
//
//  Created by Artem Yaroshenko on 24.03.2026.
//

import XCTest
@testable import ImageFeed

class MockProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: String?
    var shouldSucceed = true
    var mockURL: String?
    var mockError: Error?
    var didCallReset = false
    var fetchImageCalled = false
    var lastUsername: String?
    var shouldCheckToken = true
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        fetchImageCalled = true
        lastUsername = username
        
        if shouldCheckToken && OAuth2TokenStorage.shared.token == nil {
            let error = NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])
            completion(.failure(error))
            return
        }
        
        if shouldSucceed {
            let url = mockURL ?? "https://example.com/avatar.jpg"
            avatarURL = url
            completion(.success(url))
            
            NotificationCenter.default.post(
                name: ProfileImageService.didChangeNotification,
                object: self,
                userInfo: ["URL": url]
            )
        } else {
            let error = mockError ?? NSError(domain: "MockError", code: -1, userInfo: nil)
            completion(.failure(error))
        }
    }
    
    func reset() {
        didCallReset = true
        avatarURL = nil
    }
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
    func reset()
}

// MARK: - Tests
final class ProfileImageServiceTests: XCTestCase {
    
    var service: MockProfileImageService!
    
    override func setUp() {
        super.setUp()
        service = MockProfileImageService()
        OAuth2TokenStorage.shared.token = "test_token"
    }
    
    override func tearDown() {
        service = nil
        OAuth2TokenStorage.shared.token = nil
        super.tearDown()
    }
    
    func testFetchProfileImageURL_Success() {
        // Given
        let expectedURL = "https://example.com/avatar.jpg"
        service.mockURL = expectedURL
        service.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Fetch image URL")
        
        // When
        service.fetchProfileImageURL(username: "testuser") { result in
            // Then
            switch result {
            case .success(let url):
                XCTAssertEqual(url, expectedURL)
                XCTAssertEqual(self.service.avatarURL, expectedURL)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchProfileImageURL_NoToken() {
        // Given
        OAuth2TokenStorage.shared.token = nil
        
        let expectation = XCTestExpectation(description: "Fetch without token")
        
        // When
        service.fetchProfileImageURL(username: "testUser") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                let nsError = error as NSError
                XCTAssertEqual(nsError.code, 401)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchProfileImageURL_NetworkError() {
        // Given
        let networkError = NSError(domain: "NetworkError", code: -1009, userInfo: [NSLocalizedDescriptionKey: "No internet connection"])
        service.mockError = networkError
        service.shouldSucceed = false
        
        let expectation = XCTestExpectation(description: "Fetch with network error")
        
        // When
        service.fetchProfileImageURL(username: "testUser") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, networkError.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testReset() {
        // Given
        service.avatarURL = "some_url"
        
        // When
        service.reset()
        
        // Then
        XCTAssertNil(service.avatarURL)
        XCTAssertTrue(service.didCallReset)
    }
    
    func testFetchProfileImageURL_CallsWithCorrectUsername() {
        // Given
        let expectedUsername = "testuser123"
        service.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Fetch image URL")
        
        // When
        service.fetchProfileImageURL(username: expectedUsername) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(service.lastUsername, expectedUsername)
        XCTAssertTrue(service.fetchImageCalled)
    }
}
