//
//  PokemonResultRowViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class PokemonResultRowViewModel: ObservableObject {
    @Published private(set) var pokemonSpecies: PokemonSpecies!
    @Published private(set) var types = Set<`Type`>()
    @Published private(set) var generation: Generation!
    
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonResultRowViewModel")
    
}

extension PokemonResultRowViewModel {
    @MainActor
    func loadData(pokemon: Pokemon) async {
        logger.debug("Loading data.")
        do {
            self.pokemonSpecies = try await Globals.getPokemonSpecies(from: pokemon)
            self.types = try await Globals.getItems(`Type`.self, urls: pokemon.types.map { $0.type.url })
            self.generation = try await Globals.getGeneration(from: pokemonSpecies)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data.")
            viewLoadingState = .error(error: error)
        }
    }
    
//    func localizedName(for pokemonSpecies: PokemonSpecies, language: String) -> String {
//        pokemonSpecies.names.localizedName(language: language, default: pokemonSpecies.name)
//    }
//    
//    func localizedGenerationName(_ generation: Generation, language: String) -> String {
//        generation.names.localizedName(language: language, default: generation.name)
//    }
//    
//    func localizedTypeName(_ type: `Type`, language: String) -> String {
//        type.names.localizedName(language: language, default: type.name)
//    }
}
