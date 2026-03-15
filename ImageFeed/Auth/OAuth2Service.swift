//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 26.02.2026.
//

import Foundation

final class OAuth2Service {
    // MARK: - Static Properties
    static let shared = OAuth2Service()
    // MARK: - Privates Properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    // MARK: - Initializers
    private init() {}
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        if task != nil {
            task?.cancel()
        }
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidRequest))
            }
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            self.task = nil
            
            switch result {
            case .success(let responseBody):
                let bearerToken = responseBody.accessToken
                OAuth2TokenStorage.shared.token = bearerToken
                completion(.success(responseBody.accessToken))
            case .failure(let error):
                handleFailureResponse(error: error, completion: completion)
            }
        }
        
        self.task = task
        task.resume()
    }
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            print("Fail to take URL")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    private func handleFailureResponse(
        error: Error,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpStatusCode(let statusCode):
                print("[OAuth2Service] Ошибка сервера: HTTP статус \(statusCode)")
            case .urlRequestError(let urlError):
                print("[OAuth2Service] Сетевая ошибка запроса: \(urlError.localizedDescription)")
            case .urlSessionError:
                print("[OAuth2Service] Ошибка URLSession")
            case .decodingError(let decodingError):
                print("[OAuth2Service] Ошибка декодирования: \(decodingError.localizedDescription)")
            default:
                print("[OAuth2Service] Неизвестная сетевая ошибка: \(error.localizedDescription)")
            }
        } else {
            print("[OAuth2Service] Общая ошибка: \(error.localizedDescription)")
        }
        
        print("Полная информация об ошибке: \(error)")
        
        completion(.failure(error))
    }
}

