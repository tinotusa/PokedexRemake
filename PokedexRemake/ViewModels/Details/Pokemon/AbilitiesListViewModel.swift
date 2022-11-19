//
//  AbilitiesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for AbilitiesList.
final class AbilitiesListViewModel: ObservableObject {
    /// The abilities of the pokemon.
    @Published private var abilities = Set<Ability>()
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilitiesViewModel")
    
}

extension AbilitiesListViewModel {
    /// Loads the relevant data for the given Pokemon.
    /// - Parameter pokemon: The Pokemon to load data from.
    @MainActor
    func loadData(pokemon: Pokemon) async {
        logger.debug("Loading data.")
        do {
            self.abilities = try await Globals.getItems(Ability.self, urls: pokemon.abilities.map { $0.ability.url })
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data. \(error)")
        }
    }
    
    /// Returns a sorted array of abilities.
    /// - Returns: A sorted array of abilities.
    func sortedAbilities() -> [Ability] {
        self.abilities.sorted()
    }
}
