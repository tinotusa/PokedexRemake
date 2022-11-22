//
//  PokemonResultRowViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for PokemonResultsRow.
final class PokemonResultRowViewModel: ObservableObject {
    /// The PokemonSpecies for the Pokemon.
    @Published private(set) var pokemonSpecies: PokemonSpecies?
    /// The types of the Pokemon.
    @Published private(set) var types = Set<`Type`>()
    /// The generation of the Pokemon.
    @Published private(set) var generation: Generation?
    
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The localised name of the pokemon.
    @Published private(set) var localizedName = "Error"
    @Published private(set) var localizedGenerationName = "Error"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonResultRowViewModel")
}

extension PokemonResultRowViewModel {
    @MainActor
    /// Fetches the required data for the pokemon.
    /// - Parameters:
    ///   - pokemon: The pokemon to load data from.
    ///   - languageCode: The language code used for localisations.
    func loadData(pokemon: Pokemon, languageCode: String) async {
        logger.debug("Loading data.")
        do {
            let pokemonSpecies = try await PokemonSpecies(pokemon.species.url)
            let generation = try await Generation(pokemonSpecies.generation.url)
            self.types = try await Globals.getItems(`Type`.self, urls: pokemon.types.map { $0.type.url })
            self.generation = generation
            self.pokemonSpecies = pokemonSpecies
            
            localizedName = pokemonSpecies.localizedName(languageCode: languageCode)
            localizedGenerationName = generation.localizedName(languageCode: languageCode)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data.")
            viewLoadingState = .error(error: error)
        }
    }
}
