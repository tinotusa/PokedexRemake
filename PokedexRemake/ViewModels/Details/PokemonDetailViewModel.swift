//
//  PokemonDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 23/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for PokemonDetail.
final class PokemonDetailViewModel: ObservableObject {
    /// The PokemonSpecies of the Pokemon.
    @Published private(set) var pokemonSpecies: PokemonSpecies?
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    /// A Boolean value indicating Whether or not the moves sheet is shown.
    @Published var showingMovesSheet = false
    /// A Boolean value indicating Whether or not the abilities sheet is shown.
    @Published var showingAbilitiesSheet = false
    /// The localised name of the pokemon.
    @Published private(set) var localizedName = "Error"
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonDetailViewModel")
}

extension PokemonDetailViewModel {
    /// Loads the relevant data for the Pokemon.
    /// - Parameter pokemon: The Pokemon to load data from.
    @MainActor
    func loadData(from pokemon: Pokemon, languageCode: String) async {
        logger.debug("Loading data.")
        do {
            let pokemonSpecies = try await PokemonSpecies(pokemon.species.url)
            self.localizedName = pokemonSpecies.localizedName(languageCode: languageCode)
            self.pokemonSpecies = pokemonSpecies
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for pokemon with id: \(pokemon.id)")
        } catch {
            logger.error("Failed to get pokemon species from pokemon with id: \(pokemon.id)")
            viewLoadingState = .error(error: error)
        }
    }
}
