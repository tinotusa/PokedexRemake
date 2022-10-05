//
//  PokemonResultRowViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

final class PokemonResultRowViewModel: ObservableObject {
    func localizedName(for pokemonSpecies: PokemonSpecies, language: String) -> String {
        pokemonSpecies.names.localizedName(language: language, default: pokemonSpecies.name)
    }
    
    func localizedGenerationName(_ generation: Generation, language: String) -> String {
        generation.names.localizedName(language: language, default: generation.name)
    }
    
    func localizedTypeName(_ type: `Type`, language: String) -> String {
        type.names.localizedName(language: language, default: type.name)
    }
}
