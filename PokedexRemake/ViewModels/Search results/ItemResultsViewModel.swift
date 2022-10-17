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
        do {
            let item = try await Item(name)
            let moved = items.moveToTop(item)
            if !moved {
                self.items.insert(item, at: 0)
            }
        } catch {
            logger.error("Failed to find item with name: \(name). \(error)")
        }
    }
}
