//
//  PokemonSpecies+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension PokemonSpecies {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
    
    static var example: PokemonSpecies {
        let url = Bundle.main.url(forResource: "pokemonSpecies", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode(PokemonSpecies.self, from: data)
    }
}

extension PokemonSpecies: Equatable, Hashable {
    public static func == (lhs: PokemonSpecies, rhs: PokemonSpecies) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
