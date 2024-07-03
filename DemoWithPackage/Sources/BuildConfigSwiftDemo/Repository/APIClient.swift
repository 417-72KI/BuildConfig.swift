//
//  APIClient.swift
//  BuildConfigSwiftDemo
//
//  Created by 417.72KI on 2023/10/05.
//  Copyright © 2023 417.72KI. All rights reserved.
//

import Foundation

struct APIClient {
    var config: BuildConfig.Api
    var session: URLSession
}

extension APIClient {
    var host: URL { URL(string: "https://\(config.host)")! }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

extension APIClient {
    func endpoint<E>(_ keyPath: KeyPath<BuildConfig.Api.Endpoint, E>) -> E {
        config.endpoint[keyPath: keyPath]
    }
}

extension APIClient {
    func login(id: String, password: String) async throws -> LoginResponse {
        let endpoint = endpoint(\.login)
        let url = host.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.httpBody = try encoder.encode(LoginRequest(id: id, password: password))
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(LoginResponse.self, from: data)
    }

    @available(iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func search(_ text: String) async throws -> SearchResponse {
        let endpoint = endpoint(\.search)
        let url = host.appendingPathComponent(endpoint.path)
            .appending(queryItems: [
                URLQueryItem(name: "text", value: text)
            ])
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(SearchResponse.self, from: data)
    }
}
