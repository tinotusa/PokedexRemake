//
//  GenerationDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 1/11/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

/// The view model for GenerationDetail.
final class GenerationDetailViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The mainRegion of the Generation to be displayed.
    @Published private(set) var mainRegion: Region?
    /// The versionGroups of the Generation.
    @Published private var versionGroups = [VersionGroup]()
    /// The versions of the Generation to be displayed.
    @Published private(set) var versions = [Version]()
    /// The types of the Generation to be displayed.
    @Published private(set) var types = [`Type`]()
    /// The details of the Generation to be displayed.
    @Published private(set) var details = [InfoKey: String]()
    
    /// A Boolean value indicating whether or not showingMovesList is showing.
    @Published var showingMovesList = false
    /// A Boolean value indicating whether or not showingPokemonSpeciesList is showing.
    @Published var showingPokemonSpeciesList = false
    /// A Boolean value indicating whether or not showingAbilitiesList is showing.
    @Published var showingAbilitiesList = false
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "GenerationDetailViewModel")
    
    /// The keys for the Generation's details.
    enum InfoKey: String, CaseIterable, Identifiable {
        case abilities
        case mainRegion = "main region"
        case moves
        case pokemonSpecies = "pokemon species"
        case types
        case versionGroups = "version groups"
        
        /// The localised title for the key.
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
        /// A unique identifier for the key.
        var id: Self { self }
    }
}

extension GenerationDetailViewModel {
    /// Loads relevant Generation data for the view.
    /// - Parameters:
    ///   - generation: The Generation to load data from.
    ///   - languageCode: The language code used for localisations.
    @MainActor
    func loadData(generation: Generation, languageCode: String) async {
        logger.debug("Loading data for generation with id: \(generation.id).")
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    self.mainRegion = try await Region(generation.mainRegion.url)
                }
                group.addTask {
                    let versionGroups = try await Globals.getItems(VersionGroup.self, urls: generation.versionGroups.urls()).sorted()
                    self.versions = try await Globals.getItems(Version.self, urls: versionGroups.flatMap { $0.versions.urls() }).sorted()
                    self.versionGroups = versionGroups
                }
                group.addTask {
                    self.types = try await Globals.getItems(`Type`.self, urls: generation.types.urls()).sorted()
                }
                
                try await group.waitForAll()
            }
            
            self.details = getGenerationDetails(generation: generation, languageCode: languageCode)
            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for generation with id: \(generation.id).")
        } catch {
            viewLoadingState = .error(error: error)
            logger.debug("Failed to load data for generation with id: \(generation.id). \(error)")
        }
    }
}

private extension GenerationDetailViewModel {
    /// Gets the generation details in key value pairs.
    /// - Parameters:
    ///   - generation: The generation to get data from.
    ///   - languageCode: The language code used for localisation.
    /// - Returns: A dictionary of InfoKeys and Strings.
    func getGenerationDetails(generation: Generation, languageCode: String) -> [InfoKey: String] {
        var details = [InfoKey: String]()
        
        details[.abilities] = "\(generation.abilities.count)"
        if let mainRegion {
            details[.mainRegion] = mainRegion.localizedName(languageCode: languageCode)
        }
        details[.moves] = "\(generation.moves.count)"
        details[.pokemonSpecies] = "\(generation.pokemonSpecies.count)"
        details[.types] = "\(generation.types.count)"
        details[.versionGroups] = "\(generation.versionGroups.count)"
        
        return details
    }
}
