import Foundation

let config: AppConfig = .load()

struct AppConfig: Codable {
    let API: API
    let environment: String
    let license: [String]
    let token: Int

    enum CodingKeys: String, CodingKey {
        case API
        case environment
        case license
        case token
    }
}

extension AppConfig {
    static func load() -> AppConfig {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist") else { fatalError("Config.plist not found") }
        return load(from: filePath)
    }

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
