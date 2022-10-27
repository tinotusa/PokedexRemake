//
//  GenerationsCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class GenerationCardViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var region: Region?
    @Published private var versions = Set<Version>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "GenerationCardViewModel")
}

extension GenerationCardViewModel {
    func sortedVersions() -> [Version] {
        self.versions.sorted()
    }
    
    @MainActor
    func loadData(generation: Generation) async {
        logger.debug("Loading data.")
        do {
            self.region = try await Region(generation.mainRegion.url)
            let versionGroups = try await getVersionGroups(generation: generation)
            self.versions = try await Globals.getVersions(from: versionGroups)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data for generation with id: \(generation.id). \(error)")
        }
    }
    
    func localizedRegionName(languageCode: String) -> String {
        guard let region else {
            logger.error("Failed to get localized region name. region is nil.")
            return "Error"
        }
        return region.localizedName(languageCode: languageCode)
    }
}

private extension GenerationCardViewModel {
    func getVersionGroups(generation: Generation) async throws -> Set<VersionGroup> {
        try await withThrowingTaskGroup(of: VersionGroup.self) { group in
            for versionGroup in generation.versionGroups {
                group.addTask {
                    try await VersionGroup(versionGroup.url)
                }
            }
            
            var versionGroups = Set<VersionGroup>()
            for try await versionGroup in group {
                versionGroups.insert(versionGroup)
            }
            return versionGroups
        }
    }
}
