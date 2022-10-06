//
//  Generation+Extension.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

enum LoadJSONError: Error {
    case invalidURL
    case failedToDecode(error: Error)
}

extension Bundle {
    func loadJSON<T: Codable>(_ filename: String) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw LoadJSONError.invalidURL
        }
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            throw LoadJSONError.failedToDecode(error: error)
        }
    }
}

extension Generation {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
    
    static var example: Generation {
        do {
            return try Bundle.main.loadJSON("generation")
        } catch {
            fatalError("Failed to get generation.json from bundle.")
        }
    }
}

extension Generation: Equatable, Hashable {
    public static func == (lhs: Generation, rhs: Generation) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
