//
//  LocationResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

final class LocationResultsViewModel: ObservableObject, SearchResultsList {
    /// The state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The locations search results.
    @Published var results = [Location]() {
        didSet {
            do {
                try saveHistoryToDisk()
            } catch {
                logger.debug("Failed to save history to disk. \(error)")
            }
        }
    }
    
    @Published var showingClearHistoryDialog = false
    @Published private(set) var isSearchLoading = false
    @Published private(set) var errorMessage: String?
    private(set) var emptyPlaceholderText: LocalizedStringKey = "Search for a location."
    /// The file name of the locations history on disk
    static let saveFilename = "locationResults"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "LocationResultsViewModel")
    let fileIOManager = FileIOManager()
}

extension LocationResultsViewModel {
    /// Loads the locations search history from disk.
    @MainActor
    func loadData() {
        logger.debug("Loading data.")
        do {
            self.results = try loadHistoryFromDisk()
            viewLoadingState = .loaded
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
    @MainActor
    func search(_ name: String) async {
        isSearchLoading = true
        errorMessage = nil
        defer {
            isSearchLoading = false
        }
        do {
            let location = try await Location(name)
            let moved = moveToTop(location)
            if !moved {
                self.results.insert(location, at: 0)
            }
        } catch {
            logger.error("Failed to find location with name: \(name). \(error)")
            errorMessage = "No location with name \"\(name)\" found."
        }
    }
}
