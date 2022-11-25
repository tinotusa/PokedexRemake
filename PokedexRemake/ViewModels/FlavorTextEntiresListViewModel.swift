//
//  FlavorTextEntiresListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for FlavorTextEntriesList.
final class FlavorTextEntriesListViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The VersionGroups of the FlavorTexts.
    @Published private(set) var versionGroups = Set<VersionGroup>()
    /// The Versions of the FlavorTexts.
    @Published private(set) var versions = Set<Version>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "FlavorTextEntriesListViewModel")
}

extension FlavorTextEntriesListViewModel {
    @MainActor
    /// Loads the relevant data for the FlavorTexts
    /// - Parameter abilityFlavorTexts: The array of flavor texts to load data from.
    func loadData(abilityFlavorTexts: [CustomFlavorText]) async {
        logger.debug("Loading data.")
        do {
            self.versionGroups = try await Globals.getItems(VersionGroup.self, urls: abilityFlavorTexts.compactMap { $0.versionGroup.url })
            self.versions = try await Globals.getItems(Version.self, urls: versionGroups.flatMap { $0.versions.urls() })
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data. \(error)")
        }
    }
    
    /// Gets the versions that match the given name.
    /// - Parameter versionGroupName: The version name to look from.
    /// - Returns: An array of Versions that match the given version group name.
    func versions(named versionGroupName: String?) -> [Version] {
        guard let versionGroupName else {
            logger.debug("Failed to get version. name is nil.")
            return []
        }
        logger.debug("Getting version that match the name \(versionGroupName).")
        guard let versionGroup = versionGroups.first(where: { $0.name == versionGroupName }) else {
            logger.debug("Failed to get version group with name \(versionGroupName).")
            return []
        }
        let versions = versions.filter({ $0.versionGroup.name == versionGroup.name} )
        return Array(versions).sorted()
    }
}
