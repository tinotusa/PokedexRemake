//
//  AbilityCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class AbilityCardViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var generation: Generation!
    @Published private(set) var localizedFlavorTextEntries = [AbilityFlavorText]()
    @Published var showLongerEffectEntry = false
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityCardViewModel")
}

extension AbilityCardViewModel {
    @MainActor
    func loadData(ability: Ability, language: String) async {
        logger.debug("Loading data.")
        do {
            self.generation = try await Generation(ability.generation.url)
            self.localizedFlavorTextEntries = ability.flavorTextEntries.localizedFlavorTextEntries(language: language)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
