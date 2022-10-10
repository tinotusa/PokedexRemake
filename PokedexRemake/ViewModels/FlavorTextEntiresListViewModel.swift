//
//  FlavorTextEntiresListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class FlavorTextEntriesListViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var versionGroups = Set<VersionGroup>()
    @Published private(set) var versions = Set<Version>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "FlavorTextEntriesListViewModel")
}

extension FlavorTextEntriesListViewModel {
    func loadData(abilityFlavorTexts: [AbilityFlavorText]) async {
        logger.debug("Loading data.")
        do {
            self.versionGroups = try await Globals.getVersionGroups(from: abilityFlavorTexts)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data. \(error)")
        }
    }
}
