//
//  AbilityDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 30/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

/// View model for AbilityDetail.
final class AbilityDetailViewModel: ObservableObject {
    /// The Ability to be displayed.
    private var ability: Ability
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The generation of the Ability.
    @Published private var generation: Generation?
    /// The details of the Ability.
    @Published private(set) var abilityDetails = [AbilityDetailKey: String]()
    /// The localised verbose effect of the Ability.
    @Published private(set) var localizedEffectEntries = [VerboseEffect]()
    /// The flavor text entries of the Ability.
    @Published private var flavorTextEntries = [AbilityFlavorText]()
    /// The custom flavor text entries for the list view.
    @Published private(set) var customFlavorTexts = [CustomFlavorText]()
    /// The localized name of the Ability.
    @Published private(set) var abilityName = "Error"
    
    /// A Boolean value indicating whether or not the EffectEntriesListView is showing.
    @Published var showingEffectEntriesListView = false
    /// A Boolean value indicating whether or not the EffectChangesListView is showing.
    @Published var showingEffectChangesListView = false
    /// A Boolean value indicating whether or not the FlavorTextEntriesListView is showing.
    @Published var showingFlavorTextEntriesListView = false
    /// A Boolean value indicating whether or not the PokemonListView is showing.
    @Published var showingPokemonListView = false
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityDetailViewModel")
    
    init(ability: Ability) {
        self.ability = ability
    }
    
    /// Keys for the ability details.
    enum AbilityDetailKey: String, CaseIterable, Identifiable {
        case isMainSeries = "is main series"
        case generation
        case effectEntries = "effect entries"
        case effectChanges = "effect changes"
        case flavorTextEntries = "flavor texts"
        case pokemon
        
        /// A unique identifier for the key.
        var id: Self { self }
        
        /// A localised title for the key.
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
}

extension AbilityDetailViewModel {
    /// Loads the relevant data for the Ability.
    /// - Parameters:
    ///   - ability: The Ability to load data from.
    ///   - languageCode: The language code used for localisations.
    @MainActor
    func loadData(languageCode: String) async {
        logger.debug("Loading data.")
        do {
            self.generation = try await Generation(ability.generation.url)
            self.localizedEffectEntries = ability.effectEntries.localizedItems(for: languageCode)
            let flavorTexts = ability.flavorTextEntries.localizedItems(for: languageCode)
            flavorTexts.forEach { flavorText in
                if self.flavorTextEntries.contains(where: { $0.filteredFlavorText() == flavorText.filteredFlavorText()}) {
                    return
                }
                self.flavorTextEntries.append(flavorText)
            }
            abilityName = ability.localizedName(languageCode: languageCode)
            customFlavorTexts = flavorTextEntries.map { entry in
                CustomFlavorText(
                    flavorText: entry.filteredFlavorText(),
                    language: entry.language,
                    versionGroup: entry.versionGroup
                )
            }
            abilityDetails = getAbilityDetails(ability: ability, languageCode: languageCode)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for ability with id: \(self.ability.id).")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data for ability with id: \(self.ability.id). \(error)")
        }
    }
}

private extension AbilityDetailViewModel {
    /// Returns a dictionary of ability details and values.
    /// - Parameters:
    ///   - ability: The Ability to get details from.
    ///   - languageCode: The language code used for localisations.
    /// - Returns: A dictionary of ability details and values.
    func getAbilityDetails(ability: Ability, languageCode: String) -> [AbilityDetailKey: String] {
        var details = [AbilityDetailKey: String]()
        details[.isMainSeries] = ability.isMainSeries ? "Yes" : "No"
        if let generation {
            details[.generation] = generation.localizedName(languageCode: languageCode)
        }
        details[.effectEntries] = "\(localizedEffectEntries.count)"
        details[.effectChanges] = "\(ability.effectChanges.count)"
        details[.flavorTextEntries] = "\(flavorTextEntries.count)"
        details[.pokemon] = "\(ability.pokemon.count)"
        
        return details
    }
}
