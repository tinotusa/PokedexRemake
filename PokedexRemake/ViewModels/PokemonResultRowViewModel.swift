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
            self.pokemonSpecies = try await PokemonSpecies(pokemon.species.url)
            self.types = try await Globals.getItems(`Type`.self, urls: pokemon.types.map { $0.type.url })
            self.generation = try await Generation(pokemonSpecies.generation.url)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data.")
            viewLoadingState = .error(error: error)
        }
    }
}
