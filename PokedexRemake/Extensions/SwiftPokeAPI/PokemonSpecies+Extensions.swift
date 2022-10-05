//
//  PokemonSpecies+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension PokemonSpecies {
    static var example: PokemonSpecies {
        let url = Bundle.main.url(forResource: "pokemonSpecies", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode(PokemonSpecies.self, from: data)
    }
}

