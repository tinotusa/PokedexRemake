//
//  PokemonCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for PokemonCard.
final class PokemonCardViewModel: ObservableObject {
    /// The PokemonSpecies of the Pokemon.
    @Published private(set) var pokemonSpecies: PokemonSpecies?
    /// The Types of the Pokemon.
    @Published private(set) var types = [`Type`]()
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    @Published private(set) var localizedName = "Error"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonCardViewModel")
}

extension PokemonCardViewModel {
    /// Fetches the required Pokemon data.
    /// - Parameters:
    ///   - pokemon: The Pokemon to get data from.
    ///   - languageCode: The language code used for localisations.
    @MainActor
    func loadData(from pokemon: Pokemon, languageCode: String) async {
        logger.debug("Loading data for pokemon with id: \(pokemon.id).")
        do {
            async let pokemonSpecies = PokemonSpecies(pokemon.species.url)
            async let types = Globals.getItems(`Type`.self, urls: pokemon.types.map { $0.type.url })
            
            self.pokemonSpecies = try await pokemonSpecies
            self.types = try await types.sorted()
            localizedName = try await pokemonSpecies.localizedName(languageCode: languageCode)
            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for pokemon with id: \(pokemon.id).")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data for pokemon with id: \(pokemon.id). \(error)")
        }
    }
}
