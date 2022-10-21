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
    @MainActor
    func loadData(abilityFlavorTexts: [CustomFlavorText]) async {
        logger.debug("Loading data.")
        do {
            self.versionGroups = try await Globals.getVersionGroups(from: abilityFlavorTexts.compactMap { $0.versionGroup.url })
            self.versions = try await Globals.getVersions(from: versionGroups)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data. \(error)")
        }
    }
    
    func versions(named versionGroupName: String?) -> [Version] {
        guard let versionGroupName else {
            logger.debug("Failed to get version. name is nil.")
            return []
        }
        guard let versionGroup = versionGroups.first(where: { $0.name == versionGroupName }) else {
            logger.debug("Failed to get version group with name \(versionGroupName).")
            return []
        }
        let versions = versions.filter({ $0.versionGroup.name == versionGroup.name} )
        return Array(versions).sorted()
    }
}
