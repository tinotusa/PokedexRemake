//
//  PokemonEncounterListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 31/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for PokemonEncounterListView.
final class PokemonEncounterListViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The Pokemon to be displayed
    @Published private(set) var pokemon = [Pokemon]()
    /// The PokemonSpecies to be displayed.
    @Published private(set) var pokemonSpecies = [PokemonSpecies]()
    /// The Versions of the Pokemon.
    @Published private(set) var versions = [Version]()
    /// The EncounterMethods for the Pokemon.
    @Published private(set) var encounterMethods = Set<EncounterMethod>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonEncounterListViewModel")
}

extension PokemonEncounterListViewModel {
    @MainActor
    /// Loads the relevant data from the array of PokemonEncounters.
    /// - Parameter pokemonEncounters: The PokemonEncounters to load data from.
    func loadData(pokemonEncounters: [PokemonEncounter]) async {
        logger.debug("Loading data.")
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { @MainActor in
                    self.pokemon = try await Globals.getItems(Pokemon.self, urls: pokemonEncounters.map { $0.pokemon.url }).sorted()
                    self.pokemonSpecies = try await Globals.getItems(PokemonSpecies.self, urls: self.pokemon.map { $0.species.url }).sorted()
                }
                group.addTask { @MainActor in
                    let versions = try await Globals.getItems(Version.self, urls: pokemonEncounters.flatMap { $0.versionDetails.map { $0.version.url } })
                    self.versions.append(contentsOf: versions.sorted())
                }
                group.addTask { @MainActor in
                    let encounterMethods = try await Globals.getItems(
                        EncounterMethod.self,
                        urls: pokemonEncounters.flatMap { $0.versionDetails.flatMap { $0.encounterDetails.map { $0.method.url } } }
                    )
                    self.encounterMethods.formUnion(encounterMethods)
                }
                
                try await group.waitForAll()
            }
            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data. \(error)")
        }
    }
}
