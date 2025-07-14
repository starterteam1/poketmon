
import Foundation

class APIService: NSObject {
    static let shared = APIService()

    private override init() {
        super.init()
    }

    func fetchRandomPokemonImage(completion: @escaping (Result<String, Error>) -> Void) {
        let randomPokemonId = Int.random(in: 1...1000) // 1부터 1000 사이의 랜덤 숫자
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(randomPokemonId).png"
        
        print("DEBUG: APIService - Returning direct image URL: \(imageUrlString)")
        completion(.success(imageUrlString))
    }
}
