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
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The locations search results.
    @Published private(set) var locations = [Location]()
    /// A boolean value indicating that a search is loading.
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
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
    
    /// Searches PokeAPI for a location with the given name.
    ///
    /// If the location being searched for is already in the array, That location
    /// is moved to index 0.
    ///
    /// - parameter name: The name or id of the location to look for.
    func search(_ name: String) async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }
        do {
            let location = try await Location(name)
            let moved = self.locations.moveToTop(location)
            if !moved {
                self.locations.insert(location, at: 0)
            }
        } catch {
            logger.error("Failed to find location with name: \(name). \(error)")
            errorMessage = "No location with name \"\(name)\" found."
        }
    }
    
    /// Clears the in memory and on disk history.
    func clearHistory() {
        logger.debug("Clearing history.")
        do {
            try fileIOManager.delete(Self.saveFilename)
            self.locations = []
            logger.debug("Successfully cleared history.")
        } catch {
            logger.error("Failed to clear history. \(error)")
        }
    }
    
    func moveLocationToTop(_ location: Location) {
        let moved = self.locations.moveToTop(location)
        if !moved {
            logger.error("Failed to move location: \(location.id) to top.")
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
