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
    /// The generation of the Ability.
    @Published private(set) var generation: Generation?
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityCardViewModel")
}

extension AbilityCardViewModel {
    
    /// Loads the relevant data for the Ability.
    /// - Parameter ability: The Ability to load data from.
    @MainActor
    func loadData(ability: Ability) async {
        logger.debug("Loading data.")
        do {
            self.generation = try await Generation(ability.generation.url)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data for ability with id: \(ability.id). \(error)")
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
