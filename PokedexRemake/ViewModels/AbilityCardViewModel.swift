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
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityCardViewModel")
}

extension AbilityCardViewModel {
    func loadData(ability: Ability) async {
        logger.debug("Loading data.")
        do {
            let id = ability.generation.url.lastPathComponent
            self.generation = try await Generation(id)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
