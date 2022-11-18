//
//  MachineCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for MachineCard.
final class MachineCardViewModel: ObservableObject {
    /// The loading state for the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The machines Item.
    @Published private(set) var item: Item?
    /// The machines move.
    @Published private(set) var move: Move?
    /// The machines VersionGroup.
    @Published private(set) var versionGroup: VersionGroup?
    /// The machines Versions.
    @Published private(set) var versions = Set<Version>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MachineCardViewModel")
    
    /// Errors for the MachineCard
    enum MachineCardError: Error, LocalizedError {
        case noVersionGroup
        
        var errorDescription: String {
            switch self {
            case .noVersionGroup: return "Failed to get Version group from the machine."
            }
        }
    }
}

extension MachineCardViewModel {
    
    /// Loads the data from the given machine.
    /// - Parameter machine: The Machine to load data from.
    @MainActor
    func loadData(machine: Machine) async {
        do {
            logger.debug("Loading data.")
            self.item = try await Item(machine.item.url)
            self.move = try await Move(machine.move.url)
            self.versionGroup = try await VersionGroup(machine.versionGroup.url)
            if let versionGroup {
                self.versions = try await Globals.getItems(Version.self, urls: versionGroup.versions.map { $0.url } )
            } else {
                logger.error("Failed to get version group from machine \(machine.id).")
                viewLoadingState = .error(error: MachineCardError.noVersionGroup)
                return
            }
            viewLoadingState = .loaded
            logger.debug("Successfully loaded machine card data.")
        } catch {
            logger.error("Failed to load data for machine \(machine.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    /// Returns sorted Versions
    /// - Returns: A sorted array of Versions.
    func sortedVersions() -> [Version] {
        self.versions.sorted()
    }
}
