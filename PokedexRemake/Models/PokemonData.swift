//
//  PokemonData.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import Foundation
import SwiftPokeAPI

/// A struct that represents all the relevant data about a specific pokemon.
struct PokemonData {
    /// The pokemon being represented.
    let pokemon: Pokemon
    /// The pokemon's species.
    let pokemonSpecies: PokemonSpecies
    /// The pokemon's type(s).
    let types: [`Type`]
    /// The generation the pokemon belongs to.
    let generation: Generation?
    // TODO: Maybe make the properties optional (some views might not need certain things?)
    // TODO: Maybe have the first parameter be the pokemon and the rest are optional (look up calendar components)
}

// MARK: - Protocol conformances
extension PokemonData: Equatable, Hashable {
    static func == (lhs: PokemonData, rhs: PokemonData) -> Bool {
        return (
            lhs.pokemon.id == rhs.pokemon.id &&
            lhs.pokemonSpecies.id ==  rhs.pokemonSpecies.id
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.pokemon.id)
        hasher.combine(self.pokemonSpecies.id)
    }
}
