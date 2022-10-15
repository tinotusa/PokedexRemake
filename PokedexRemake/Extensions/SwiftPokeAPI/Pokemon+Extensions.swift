//
//  Pokemon+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Pokemon {
    var weightInKG: Double {
        Double(self.weight) / 10.0
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension Pokemon {
    static var example: Pokemon {
        let url = Bundle.main.url(forResource: "pokemon", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode(Pokemon.self, from: data)
    }
}
