//
//  MachinesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class MachinesListViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private var machines = Set<Machine>()
    @Published private(set) var hasNextPage = true
    
    private var offset = 0
    private let limit = 20
    private var page = 0 {
        didSet {
            offset = page * limit
        }
    }
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MachinesListViewModel")
}

extension MachinesListViewModel {
    func sortedMachines() -> [Machine] {
        self.machines.sorted()
    }
    
    @MainActor
    func loadData(urls: [URL]) async {
        logger.debug("Loading data.")
        do {
            self.machines = try await getMachines(urls: urls)
            page += 1
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}

private extension MachinesListViewModel {
    func getMachines(urls: [URL]) async throws -> Set<Machine>{
        try await withThrowingTaskGroup(of: Machine.self) { group in
            for (i, url) in urls.enumerated() where i < limit {
                group.addTask {
                    return try await Machine(url)
                }
            }
            
            var machines = Set<Machine>()
            for try await machine in group {
                machines.insert(machine)
            }
            return machines
        }
    }
}
