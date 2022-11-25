//
//  AbilityExpandableTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for AbilityExpandableTab
final class AbilityExpandableTabViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The Generation of the Ability.
    @Published private(set) var generation: Generation?
    /// The localised flavour texts of the Ability.
    @Published private(set) var localizedFlavorTextEntries = [AbilityFlavorText]()
    /// A Boolean value indicating whether or not the longer effect text is being shown.
    @Published var showLongerEffectEntry = false
    /// The localised generation name.
    @Published private(set) var localizedGenerationName = "Error"
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityExpandableTabViewModel")
}

extension AbilityExpandableTabViewModel {
    /// Loads the relevant data for an Ability.
    /// - Parameters:
    ///   - ability: The Ability to load data from.
    ///   - languageCode: The language code used for localisations.
    @MainActor
    func loadData(ability: Ability, languageCode: String) async {
        logger.debug("Loading data for ability with id: \(ability.id).")
        do {
            let generation = try await Generation(ability.generation.url)
            self.generation = generation
            self.localizedFlavorTextEntries = ability.flavorTextEntries.localizedItems(for: languageCode)
            self.localizedGenerationName = generation.localizedName(languageCode: languageCode)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for ability with id: \(ability.id).")
        } catch {
            logger.error("Failed to load data for ability with id: \(ability.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
