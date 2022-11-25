//
//  PastMoveValuesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for PastMoveValues.
final class PastMoveValuesListViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The Types of the PastMoves.
    @Published private(set) var types = Set<`Type`>()
    /// The VersionGroups of the PastMoves.
    @Published private(set) var versionGroups = Set<VersionGroup>()
    /// The Versions of the past moves.
    @Published private(set) var versions = Set<Version>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PastMoveValuesListViewModel")
}

extension PastMoveValuesListViewModel {
    @MainActor
    func loadData(pastValues: [PastMoveStatValues]) async {
        logger.debug("Loading data.")
        do {
            self.types = try await Globals.getItems(`Type`.self, urls: pastValues.compactMap { $0.type?.url })
            self.versionGroups = try await Globals.getItems(VersionGroup.self, urls: pastValues.compactMap { $0.versionGroup.url })
            self.versions = try await Globals.getItems(Version.self, urls: versionGroups.flatMap { $0.versions.map { $0.url } })
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
