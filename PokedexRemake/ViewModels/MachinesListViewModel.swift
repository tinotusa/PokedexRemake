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
    @Published private var machines = Set<Machine>() {
        willSet {
            if abs(newValue.count - machines.count) < limit {
                hasNextPage = false
            }
        }
    }
    @Published private(set) var hasNextPage = true
    private var urls = [URL]()
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
        self.urls = urls
        do {
            self.machines = try await getMachines()
            page += 1
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func getNextPage() async {
        logger.debug("Getting next page.")
        guard hasNextPage else {
            logger.error("Failed to get next page. hasNextPage is false.")
            return
        }
        do {
            let machines = try await getMachines()
            self.machines.formUnion(machines)
            page += 1
            logger.debug("Successfully got next page.")
        } catch {
            logger.error("Failed to get next page: \(error)")
        }
    }
}

private extension MachinesListViewModel {
    func getMachines() async throws -> Set<Machine>{
        try await withThrowingTaskGroup(of: Machine.self) { group in
            for (i, url) in self.urls.enumerated() where i >= offset && i < offset + limit {
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
