//
//  ItemResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

final class ItemResultsViewModel: ObservableObject, SearchResultsList {
    private(set) var emptyPlaceholderText: LocalizedStringKey = "Search for an item."
    
    @Published var results = [Item]() {
        didSet {
            do {
                try saveHistoryToDisk()
            } catch {
                logger.error("Failed to save history to disk. \(error)")
            }
        }
    }
    @Published private(set) var hasNextPage = true
    @Published private var nextPageURL: URL? {
        didSet {
            if nextPageURL == nil { hasNextPage = false }
        }
    }
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var errorMessage: String?
    @Published private(set) var isSearchLoading = false
    @Published var showingClearHistoryDialog = false
    
    let fileIOManager = FileIOManager()
    static let saveFilename = "itemResults"
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ItemResultsViewModel")
}

extension ItemResultsViewModel {
    @MainActor
    func loadData() {
        logger.debug("Loading data.")
        do {
            self.results = try loadHistoryFromDisk()
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data from disk.")
        } catch CocoaError.fileReadNoSuchFile {
            logger.debug("The file \(Self.saveFilename) has not been created yet.")
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to load data from disk. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    /// Searches for an Item with the given name.
    /// - parameter name: The name to search for an item with.
    @MainActor
    func search(_ name: String) async {
        isSearchLoading = true
        errorMessage = nil
        defer {
            isSearchLoading = false
        }
        do {
            let item = try await Item(name)
            let moved = moveToTop(item)
            if !moved {
                self.results.insert(item, at: 0)
            }
        } catch {
            logger.error("Failed to find item with name: \(name). \(error)")
            errorMessage = "Failed to find an item with the name \(name)."
        }
    }
}
