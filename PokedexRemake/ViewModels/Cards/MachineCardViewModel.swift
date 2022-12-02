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
    /// The machine to display.
    private var machine: Machine
    /// The loading state for the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The machines Item.
    @Published private(set) var item: Item?
    /// The machines move.
    @Published private(set) var move: Move?
    /// The machines VersionGroup.
    @Published private(set) var versionGroups = [VersionGroup]()
    /// The machines Versions.
    @Published private(set) var versions = [Version]()
    /// The api VersionGroups
    @Published private(set) var apiVersionGroups = [NamedAPIResource]()
    
    /// The localised name for the Machine's Item.
    @Published private(set) var itemName = "Error"
    /// The localised name for the Machine's Move.
    @Published private(set) var moveName = "Error"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MachineCardViewModel")
    
    /// Creates the view model/
    /// - Parameter machine: The Machine to display.
    init(machine: Machine, versionGroups: [NamedAPIResource]) {
        self.machine = machine
        self.apiVersionGroups = versionGroups
    }
    
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
    func loadData(languageCode: String) async {
        do {
            logger.debug("Loading data.")
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    let item = try await Item(self.machine.item.url)
                    self.item = item
                    self.itemName = item.localizedName(languageCode: languageCode)
                }
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    let move = try await Move(self.machine.move.url)
                    self.move = move
                    self.moveName = move.localizedName(languageCode: languageCode)
                }
                
                for apiVersionGroup in self.apiVersionGroups {
                    group.addTask { @MainActor [weak self] in
                        guard let self else { return }
                        let versionGroup = try await VersionGroup(apiVersionGroup.url)
                        self.versionGroups.append(versionGroup)
                    }
                }
                
                try await group.waitForAll()
            }

            self.versions = try await Globals.getItems(Version.self, urls: versionGroups.flatMap { $0.versions.urls() } ).sorted()

            viewLoadingState = .loaded
            logger.debug("Successfully loaded machine card data.")
        } catch {
            logger.error("Failed to load data for machine \(self.machine.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
