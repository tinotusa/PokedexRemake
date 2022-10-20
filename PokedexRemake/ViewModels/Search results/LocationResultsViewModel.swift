//
//  LocationResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class LocationResultsViewModel: ObservableObject {
    /// The state of the view.
    @Published private var viewLoadingState = ViewLoadingState.loading
    /// The locations search results.
    @Published private var locations = [Location]()
    /// The file name of the locations history on disk
    private static let saveFilename = "locationResults"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "LocationResultsViewModel")
    private let fileIOManager = FileIOManager()
}

extension LocationResultsViewModel {
    /// Loads the locations search history from disk.
    func loadData() {
        logger.debug("Loading data.")
        do {
            self.locations = try loadHistoryFromDisk()
            viewLoadingState = .loading
            logger.debug("Successfully loaded data.")
        } catch CocoaError.fileReadNoSuchFile {
            logger.debug("File \(Self.saveFilename) has not been created.")
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}

private extension LocationResultsViewModel {
    /// Loads the locations search history from disk.
    /// - returns: An array of Locations.
    func loadHistoryFromDisk() throws -> [Location] {
        try fileIOManager.load([Location].self, documentName: Self.saveFilename)
    }
    
    /// Saves the locations search history from disk.
    func saveHistoryToDisk() {
        logger.debug("Saving locations history.")
        do {
            try fileIOManager.write(self.locations, documentName: Self.saveFilename)
            logger.debug("Successfully saved locations history.")
        } catch {
            logger.error("Failed to save locations history to disk. \(error)")
        }
    }
}
