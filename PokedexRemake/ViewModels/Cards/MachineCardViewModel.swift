//
//  MachineCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class MachineCardViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var item: Item?
    @Published private(set) var move: Move?
    @Published private(set) var versionGroup: VersionGroup?
    @Published private(set) var versions = Set<Version>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MachineCardViewModel")
    
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
    @MainActor
    func loadData(machine: Machine) async {
        do {
            self.item = try await Item(machine.item.url)
            self.move = try await Move(machine.move.url)
            self.versionGroup = try await VersionGroup(machine.versionGroup.url)
            if let versionGroup {
                self.versions = try await Globals.getVersions(from: [versionGroup])
            } else {
                logger.error("Failed to get version group from machine \(machine.id).")
                viewLoadingState = .error(error: MachineCardError.noVersionGroup)
            }
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to load data for machine \(machine.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    func sortedVersions() -> [Version] {
        self.versions.sorted()
    }
}
