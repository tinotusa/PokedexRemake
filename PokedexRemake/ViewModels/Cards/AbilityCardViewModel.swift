//
//  AbilityCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class AbilityCardViewModel: ObservableObject {
    @Published private(set) var generation: Generation!
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityCardViewModel")
}

extension AbilityCardViewModel {
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
    
    func localizedGenerationName(language: String) -> String {
        generation.localizedName(for: language)
    }
}
