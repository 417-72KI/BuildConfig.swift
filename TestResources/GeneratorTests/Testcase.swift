//
// This is a generated file, do not edit!
// Generated by BuildConfig.swift, see https://github.com/417-72KI/BuildConfig.swift
//

import Foundation

struct AppConfig: Codable {
    static let `default`: AppConfig = .load()

    let API: API
    let boot: Boot
    let environment: String
    let isDebug: Bool
    let license: [String]
    let pi: Double
    let token: Int

    enum CodingKeys: String, CodingKey {
        case API
        case boot
        case environment
        case isDebug
        case license
        case pi
        case token
    }
}

private extension AppConfig {
    static func load() -> AppConfig {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist") else { fatalError("Config.plist not found") }
        return load(from: filePath)
    }
}

extension AppConfig {
    static func load(from filePath: String) -> AppConfig {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            return try PropertyListDecoder().decode(AppConfig.self, from: data)
        } catch {
            fatalError("\(filePath) is invalid. cause: \(error)")
        }
    }
}

extension AppConfig {
    struct API: Codable {
        let domain: String
        let path: Path

        enum CodingKeys: String, CodingKey {
            case domain
            case path
        }
    }
}

extension AppConfig.API {
    struct Path: Codable {
        let login: Login

        enum CodingKeys: String, CodingKey {
            case login
        }
    }
}

extension AppConfig.API.Path {
    struct Login: Codable {
        let method: String
        let path: String

        enum CodingKeys: String, CodingKey {
            case method
            case path
        }
    }
}

extension AppConfig {
    struct Boot: Codable {
        let message: String

        enum CodingKeys: String, CodingKey {
            case message
        }
    }
}
