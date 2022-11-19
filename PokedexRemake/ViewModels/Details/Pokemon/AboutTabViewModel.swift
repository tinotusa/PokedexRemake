//
//  AboutTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import Foundation
import SwiftUI
import SwiftPokeAPI
import os

/// View Model for AboutTab.
final class AboutTabViewModel: ObservableObject {
    /// The PokemonSpecies to be displayed.
    @Published private(set) var pokemonSpecies: PokemonSpecies?
    /// The types to be displayed.
    @Published private(set) var types = Set<`Type`>()
    /// The items to be displayed.
    @Published private(set) var items = Set<Item>()
    /// The versions to be displayed.
    @Published private(set) var versions = Set<Version>()
    /// The Pokemon's flavor text entries.
    @Published private(set) var flavorTextEntries = [FlavorText]()
    
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AboutTabViewModel")
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// Whether or not all of the entries are begin shown.
    @Published var showAllEntries = false
    
    @Published private(set) var aboutInfo = [AboutInfo: String]()
    let minEntryCount = 3
    
    enum AboutInfo: String, CaseIterable, Identifiable {
        case name
        case types
        case height
        case weight
        case isDefault = "is default"
        case heldItems = "held items"
        case baseExperience = "base experience"
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
        
        var id: Self { self }
    }
}

extension AboutTabViewModel {
    /// Loads relevant data for the AboutTab.
    /// - Parameters:
    ///   - pokemon: The Pokemon to load data from.
    ///   - languageCode: The language code used for localisations.
    @MainActor
    func loadData(pokemon: Pokemon, languageCode: String) async {
        logger.debug("Loading data.")
        do {
            let pokemonSpecies = try await PokemonSpecies(pokemon.species.url)
            
            async let versions = Globals.getItems(Version.self, urls: pokemonSpecies.flavorTextEntries.compactMap { $0.version?.url })
            async let items = Globals.getItems(Item.self, urls: pokemon.heldItems.map { $0.item.url })
            async let types = Globals.getItems(`Type`.self, urls: pokemon.types.map { $0.type.url })
            
            self.pokemonSpecies = pokemonSpecies
            self.versions = try await versions
            self.items = try await items
            self.types = try await types
            
            self.aboutInfo = getAboutInfo(pokemon: pokemon, pokemonSpecies: pokemonSpecies, languageCode: languageCode)
            self.flavorTextEntries = pokemonSpecies.flavorTextEntries.localizedItems(for: languageCode)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for pokemon \(pokemon.id)")
        } catch {
            logger.error("Failed to load data for pokemon \(pokemon.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}

// MARK: Private functions
private extension AboutTabViewModel {
    /// Gets all the relevant fields about a pokemon.
    /// - Parameters:
    ///   - pokemon: The Pokemon to get data from.
    ///   - pokemonSpecies: The PokemonSpecies to get data from.
    ///   - languageCode: The language code used for localisation.
    /// - Returns: A dictionary of AboutInfo and String
    func getAboutInfo(pokemon: Pokemon, pokemonSpecies: PokemonSpecies, languageCode: String) -> [AboutInfo: String] {
        var aboutInfo: [AboutInfo: String] = [:]
        
        aboutInfo[.name] = pokemonSpecies.localizedName(languageCode: languageCode)
        aboutInfo[.types] = "\(pokemon.types.count) types"
        aboutInfo[.height] = Measurement(value: Double(pokemon.height), unit: UnitLength.decimeters).formatted()
        aboutInfo[.weight] = Measurement(value: Double(pokemon.weightInKG), unit: UnitMass.kilograms).formatted()
        aboutInfo[.isDefault] = pokemon.isDefault ? "Yes" : "No"
        aboutInfo[.heldItems] = "\(pokemon.heldItems.count) items"
        aboutInfo[.baseExperience] = "\(pokemon.baseExperience ?? 0)"
        
        return aboutInfo
    }
}
