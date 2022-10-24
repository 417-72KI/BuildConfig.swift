enum Template: CaseIterable {
    case header
    case root
    case loadExtension
    case `struct`
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
                    guard let filePath = Bundle.main.path(forResource: "BuildConfig", ofType: "plist") else { fatalError("BuildConfig.plist not found") }
                    return load(from: filePath)
                }
            }

            extension BuildConfig {
                static func load(from filePath: String) -> BuildConfig {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                        return try PropertyListDecoder().decode(BuildConfig.self, from: data)
                    } catch {
                        fatalError("\\(filePath) is invalid. cause: \\(error)")
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
        }
    }
}
