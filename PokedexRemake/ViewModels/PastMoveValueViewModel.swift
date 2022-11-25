//
//  PastMoveValueViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

/// View model for PastMoveView.
final class PastMoveValueViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The type of the PastMoveValue.
    @Published private(set) var type: `Type`?
    /// The VersionGroup of the PastMoveValue.
    @Published private var versionGroup: VersionGroup?
    /// The Versions of the PastMoveValue.
    @Published private var versions = Set<Version>()
    /// Past move values and their keys.
    @Published private(set) var pastValues = [PastValueKey: String]()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PastMoveListViewModel")
    
    /// Keys for the past values.
    enum PastValueKey: String, CaseIterable, Identifiable {
        case type
        case accuracy
        case effectChance = "effect chance"
        case power
        case pp
        case effectEntries = "effect entries"
        
        /// A unique identifier.
        var id: Self { self }
        
        /// A localised title for the key.
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
}

extension PastMoveValueViewModel {
    func sortedVersion() -> [Version] {
        self.versions.sorted()
    }
    
    @MainActor
    /// Loads the relevant data for the view.
    /// - Parameter pastValue: The values to load data from.
    func loadData(pastValue: PastMoveStatValues) async {
        logger.debug("Loading data.")
        do {
            if let typeURL = pastValue.type?.url {
                self.type = try await `Type`(typeURL)
            }
            self.versionGroup = try await VersionGroup(pastValue.versionGroup.url)
            if let versionGroup {
                self.versions = try await Globals.getItems(Version.self, urls: versionGroup.versions.map { $0.url })
            }
            viewLoadingState = .loaded
            self.pastValues = getPastValues(pastValue: pastValue)
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}

private extension PastMoveValueViewModel {
    /// Returns the values of the past value in a dictionary.
    /// - Parameter pastValue: The PastMoveStat to get the values from.
    /// - Returns: A dictionary of the past key names and their value.
    func getPastValues(pastValue: PastMoveStatValues) -> [PastValueKey: String] {
        logger.debug("Getting past value keys.")
        var values = [PastValueKey: String]()
        if let type {
            values[.type] = type.name
        }
        if let accuracy = pastValue.accuracy {
            values[.accuracy] = accuracy.formatted(.percent)
        }
        if let effectChance = pastValue.effectChance {
            values[.effectChance] = effectChance.formatted(.percent)
        }
        if let power = pastValue.power {
            values[.power] = "\(power)"
        }
        if let pp = pastValue.pp {
            values[.pp] = "\(pp)"
        }
        if !pastValue.effectEntries.isEmpty {
            values[.effectEntries] = "\(pastValue.effectEntries.count)"
        }
        logger.debug("Successfully got past value keys.")
        return values
    }
}
