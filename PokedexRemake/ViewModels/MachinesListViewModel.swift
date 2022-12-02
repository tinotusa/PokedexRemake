//
//  MachinesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for MachinesList.
final class MachinesListViewModel: ObservableObject, Pageable {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The machines to be displayed.
    @Published private(set) var machines = [Machine]()
    /// The current pages information.
    @Published private(set) var pageInfo = PageInfo()
    /// The names of the machines and their versions.
    @Published private(set) var machineVersions = [String: [NamedAPIResource]]()
    /// The urls of the machines to fetch.
    private var urls: [URL]
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MachinesListViewModel")
    
    /// Creates the view model.
    /// - Parameter urls: The machine urls to load from.
    init(urls: [URL]) {
        self.urls = urls
    }
}

extension MachinesListViewModel {
    @MainActor
    /// Loads the page data from the pageInfo.
    func loadPage() async {
        logger.debug("Loading data.")
        do {
            let machines = try await Globals.getItems(
                Machine.self,
                urls: urls,
                limit: pageInfo.limit,
                offset: pageInfo.offset
            ).sorted()
            
            machines.forEach { machine in
                if self.machines.contains(where: { $0.item.name == machine.item.name }) {
                    return
                }
                self.machines.append(machine)
            }
            
            machines.forEach { machine in
                if let name = machine.item.name {
                    self.machineVersions[name, default: []].append(machine.versionGroup)
                } else {
                    logger.error("Machine \(machine.id) has no item name.")
                }
            }
            
            pageInfo.updateOffset()
            pageInfo.hasNextPage = machines.count == pageInfo.limit
            if !hasLoadedFirstPage {
                viewLoadingState = .loaded
                pageInfo.hasLoadedFirstPage = true
            }
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            if !hasLoadedFirstPage {
                viewLoadingState = .error(error: error)
            }
        }
    }
}
