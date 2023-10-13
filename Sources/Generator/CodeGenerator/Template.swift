enum Template {
    case header
    case root
    case loadExtension
    case `struct`
    case rawData(asBinary: Bool)
}

extension Template {
    var code: String {
        switch self {
        case .header:
            return """
            //
            // This is a generated file, do not edit!
            // Generated by BuildConfig.swift, see https://github.com/417-72KI/BuildConfig.swift
            //

            import Foundation
            """
        case .root:
            return """
            struct BuildConfig: Codable {
                static let `default`: BuildConfig = .load()
                {% if properties %}

                {% for property in properties  %}
                let {{ property.name }}: {{ property.type }}
                {% endfor %}

                {% endif %}
                {% if codingKeys %}
                enum CodingKeys: String, CodingKey {
                    {% for codingKey in codingKeys %}
                    case {{ codingKey.key }}{% if codingKey.key != codingKey.origin %} = "{{ codingKey.origin }}"{% endif %}\n
                    {% endfor %}
                }
                {% endif %}
            }
            """
        case .loadExtension:
            return """
            private extension BuildConfig {
                static func load() -> BuildConfig {
                    load(from: rawData)
                }
            }

            extension BuildConfig {
                static func load(from filePath: String) -> BuildConfig {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                        return load(from: data)
                    } catch {
                        fatalError("\\(filePath) is invalid. cause: \\(error)")
                    }
                }

                static func load(from data: Data) -> BuildConfig {
                    do {
                        return try JSONDecoder().decode(BuildConfig.self, from: data)
                    } catch {
                        fatalError("Invalid data (\\(String(data: data, encoding: .utf8) ?? ""). cause: \\(error)")
                    }
                }
            }
            """
        case .struct:
            return """
            extension {{ parent }} {
                struct {{ name }}: Codable {
                    {% if properties %}
                    {% for property in properties  %}
                    let {{ property.name }}: {{ property.type }}
                    {% endfor %}

                    {% endif %}
                    {% if codingKeys %}
                    enum CodingKeys: String, CodingKey {
                        {% for codingKey in codingKeys %}
                        case {{ codingKey.key }}{% if codingKey.key != codingKey.origin %} = "{{ codingKey.origin }}"{% endif %}\n
                        {% endfor %}
                    }
                    {% endif %}
                }
            }
            """
        case let .rawData(asBinary):
            if asBinary {
                return #"private let rawData = Data(base64Encoded: "{{ rawData }}")!"#
            }
            return """
                private let rawData = \"\"\"
                {{ rawData }}
                \"\"\".data(using: .utf8)!
                """
        }
    }
}
