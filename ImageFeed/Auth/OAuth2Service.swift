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
    // MARK: - Initializers
    private init() {}
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidRequest))
                print("Network error, invalid request")
            }
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                self.handleSuccessResponse(data: data, completion: completion)
            case .failure(let error):
                self.handleFailureResponse(error: error, completion: completion)
            }
        }
        
        task.resume()
    }
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
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
    
    private func handleSuccessResponse(
        data: Data,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        do {
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            
            let bearerToken = tokenResponse.accessToken
            OAuth2TokenStorage.shared.token = bearerToken
            completion(.success(bearerToken))
            
        } catch let decodingError {
            completion(.failure(NetworkError.decodingError(decodingError)))
        }
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
        
        completion(.failure(error))
    }
}
