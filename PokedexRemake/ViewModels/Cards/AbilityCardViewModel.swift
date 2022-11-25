//
//  AbilityCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for AbilityCard.
final class AbilityCardViewModel: ObservableObject {
    /// The ability to load data from.
    private var ability: Ability
    /// The generation of the Ability.
    @Published private(set) var generation: Generation?
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The localised ability name.
    @Published private(set) var abilityName = "Error"
    /// The localised ability effect entry.
    @Published private(set) var effectEntry = "Error"
    /// The localised generation name.
    @Published private(set) var generationName = "Error"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityCardViewModel")
    
    /// Creates the view model.
    /// - Parameter ability: The Ability to load data from.
    init(ability: Ability) {
        self.ability = ability
    }
}

extension AbilityCardViewModel {
    @MainActor
    /// Loads the relevant data for the Ability.
    /// - Parameter ability: The Ability to load data from.
    func loadData(languageCode: String) async {
        logger.debug("Loading data.")
        do {
            let generation = try await Generation(ability.generation.url)
            self.generation = generation
            abilityName = ability.localizedName(languageCode: languageCode)
            effectEntry = ability.effectEntries.localizedEntry(language: languageCode, shortVersion: true)
            generationName = generation.localizedName(languageCode: languageCode)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data for ability with id: \(self.ability.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    /// Returns the localised generation name.
    /// - Parameter language: The language code to localise with.
    /// - Returns: The localised generation name or "Error".
    func localizedGenerationName(language: String) -> String {
        if let generation {
            return generation.localizedName(languageCode: language)
        }
        logger.error("Failed to get localised generation name. Generation is nil.")
        return "Error"
    }
}
