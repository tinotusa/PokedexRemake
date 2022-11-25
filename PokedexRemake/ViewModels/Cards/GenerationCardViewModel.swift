//
//  GenerationsCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for GenerationCard.
final class GenerationCardViewModel: ObservableObject {
    /// The generation to display.
    private var generation: Generation
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The Region of the Generation.
    @Published private var region: Region?
    /// The versions of this Generation.
    @Published private(set) var versions = [Version]()
    /// The localised generation name.
    @Published private(set) var generationName = "Error"
    /// The localised region name.
    @Published private(set) var regionName = "Error"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "GenerationCardViewModel")
    
    /// Creates the view model.
    /// - Parameter generation: The Generation to display.
    init(generation: Generation) {
        self.generation = generation
    }
}

extension GenerationCardViewModel {
    @MainActor
    /// Loads the data from the Generation.
    /// - Parameter languageCode: The language code used for localisations.
    func loadData(languageCode: String) async {
        logger.debug("Loading data for generation with id: \(self.generation.id).")
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    let region = try await Region(self.generation.mainRegion.url)
                    self.region = region
                    self.regionName = region.localizedName(languageCode: languageCode)
                }
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    let versionGroups = try await Globals.getItems(VersionGroup.self, urls: self.generation.versionGroups.map { $0.url })
                    self.versions = try await Globals.getItems(Version.self, urls: versionGroups.flatMap { $0.versions.map { $0.url } }).sorted()
                }
                
                try await group.waitForAll()
            }
            
            generationName = generation.localizedName(languageCode: languageCode)
            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for generation with id: \(self.generation.id).")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data for generation with id: \(self.generation.id). \(error)")
        }
    }
}
