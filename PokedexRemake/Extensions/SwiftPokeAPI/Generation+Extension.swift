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
    func loadJSON<T: Codable>(_ filename: String) -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to find url from filename: \(filename).")
        }
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            fatalError("Failed to decode data from filename: \(filename).")
        }
    }
}

extension Generation {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
    
    static var example: Generation {
        Bundle.main.loadJSON("generation")
    }
}
