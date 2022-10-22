//
//  PastMoveValuesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class PastMoveValuesListViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var types = Set<`Type`>()
    @Published private(set) var versionGroups = Set<VersionGroup>()
    @Published private(set) var versions = Set<Version>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PastMoveValuesListViewModel")
}

extension PastMoveValuesListViewModel {
    @MainActor
    func loadData(pastValues: [PastMoveStatValues]) async {
        logger.debug("Loading data.")
        do {
            self.types = try await Globals.getTypes(urls: pastValues.compactMap { $0.type?.url })
            self.versionGroups = try await Globals.getVersionGroups(from: pastValues.compactMap { $0.versionGroup.url })
            self.versions = try await Globals.getVersions(from: versionGroups)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
