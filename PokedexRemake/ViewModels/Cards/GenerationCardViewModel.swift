//
//  GenerationsCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for GenerationCard.
final class GenerationCardViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The Region of the Generation.
    @Published private(set) var region: Region?
    /// The versions of this Generation.
    @Published private var versions = Set<Version>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "GenerationCardViewModel")
}

extension GenerationCardViewModel {
    /// Returns the Versions of the Generation in sorted order.
    /// - Returns: A sorted array of Versions.
    func sortedVersions() -> [Version] {
        self.versions.sorted()
    }
    
    @MainActor
    /// Loads the data from the Generation.
    /// - Parameter generation: The Generation to load data from.
    func loadData(generation: Generation) async {
        logger.debug("Loading data.")
        do {
            self.region = try await Region(generation.mainRegion.url)
            let versionGroups = try await Globals.getItems(VersionGroup.self, urls: generation.versionGroups.map { $0.url })
            self.versions = try await Globals.getItems(Version.self, urls: versionGroups.flatMap { $0.versions.map { $0.url } })
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data for generation with id: \(generation.id). \(error)")
        }
    }
    
    /// Returns the localised name for the Region.
    /// - Parameter languageCode: The language code to localise with.
    /// - Returns: The localised name or "Error"
    func localizedRegionName(languageCode: String) -> String {
        guard let region else {
            logger.error("Failed to get localized region name. region is nil.")
            return "Error"
        }
        return region.localizedName(languageCode: languageCode)
    }
}
