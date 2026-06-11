//
//  ApiService.swift
//  TesteVIPERsurpresaSeiro
//
//  Created by Thiago on 11/06/26.
//

import Foundation

protocol ApiServiceProtocol: AnyObject {
    func getPosts() async throws -> NewsResponseEntity
}

final class ApiService: ApiServiceProtocol {

    private let apiKey = "ef01734ada56459b9b60caa572c6eb30"

    func getPosts() async throws -> NewsResponseEntity {

        var components = URLComponents(string: "https://newsapi.org/v2/top-headlines")!
        components.queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]

        guard let url = components.url else {
            throw ApiError.invalidURL
            
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ApiError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let result = try decoder.decode(NewsResponseEntity.self, from: data)
            return result

        } catch {
            throw ApiError.decodingFailed(error)
        }
    }
    

}

enum ApiError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed(Error)
}
