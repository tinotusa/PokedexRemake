//
//  ItemResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class ItemResultsViewModel: ObservableObject {
    @Published private(set) var items = [Item]() {
        didSet {
            saveHistoryToDisk()
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
    @Published private(set) var isLoading = false
    @Published var showingClearHistoryDialog = false
    
    private let fileIOManager = FileIOManager()
    static let saveFilename = "itemResults"
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ItemResultsViewModel")
}

extension ItemResultsViewModel {
    @MainActor
    func loadData() {
        logger.debug("Loading data.")
        do {
            self.items = try fileIOManager.load([Item].self, documentName: Self.saveFilename)
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
    
    func saveHistoryToDisk() {
        do {
            try fileIOManager.write(self.items, documentName: Self.saveFilename)
        } catch {
            logger.error("Failed to write search history to disk. \(error)")
        }
    }
    
    /// Searches for an Item with the given name.
    /// - parameter name: The name to search for an item with.
    @MainActor
    func search(_ name: String) async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }
        do {
            let item = try await Item(name)
            let moved = items.moveToTop(item)
            if !moved {
                self.items.insert(item, at: 0)
            }
        } catch {
            logger.error("Failed to find item with name: \(name). \(error)")
            errorMessage = "Failed to find an item with the name \(name)."
        }
    }
    
    /// Moves the given item to index 0.
    /// - parameter item: The item to move.
    @MainActor
    func moveToTop(_ item: Item) {
        let moved = items.moveToTop(item)
        if !moved {
            logger.error("Failed to move item \(item.id). Item wasn't in the array")
        }
    }
    
    /// Clears the itemsearch history and deletes it from disk.
    @MainActor
    func clearHistory() {
        do {
            try fileIOManager.delete(Self.saveFilename)
            self.items = []
            logger.debug("Successfully deleted items history from disk.")
        } catch {
            logger.error("Failed to delete file name \(Self.saveFilename) from disk. \(error)")
        }
    }
}
