
import Foundation

// MARK: - Pokemon
struct Pokemon: Codable {
    let sprites: Sprites
}

// MARK: - Sprites
struct Sprites: Codable {
    let frontDefault: String

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}
