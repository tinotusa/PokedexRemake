//
//  MoveResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

final class SearchResultsListViewModel<T: Identifiable & Codable & Equatable & SearchableByName>: ObservableObject, SearchResultsList {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published var results = [T]() {
        didSet {
            do {
                try saveHistoryToDisk()
            } catch {
                logger.error("Failed to save history to disk. \(error)")
            }
        }
    }
    @Published var showingClearHistoryDialog = false
    @Published private(set) var isSearchLoading = false
    @Published private(set) var errorMessage: String?
    private(set) var emptyPlaceholderText: LocalizedStringKey = "Search for an item."
    
    var saveFilename: String
    let fileIOManager = FileIOManager()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "SearchResultsViewModel")
    
    init(saveFilename: String) {
        self.saveFilename = saveFilename
    }
}

extension SearchResultsListViewModel {
    /// Loads MoveResults from disk.
    @MainActor
    func loadData() {
        do {
            self.results = try loadHistoryFromDisk()
            viewLoadingState = .loaded
        } catch CocoaError.fileReadNoSuchFile {
            // Do nothing file will be created on save.
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }

    @MainActor
    func search(_ name: String) async {
        logger.debug("Searching for item with name: \(name).")
        if name.isEmpty {
            logger.debug("Search text is empty.")
            return
        }
        errorMessage = nil
        isSearchLoading = true
        defer { isSearchLoading = false }

        do {
            let item = try await T(name)
            if self.results.contains(item) {
                moveToTop(item)
                logger.debug("Item already in history. Moving it to top.")
                return
            }
            self.results.insert(item, at: 0)
            logger.debug("Successfully found item.")
        } catch PokeAPIError.invalidServerResponse(let code) where code == 404 {
            if let id = Int(name) {
                errorMessage = "Couldn't find item with id: \(id)."
            } else {
                errorMessage = "Couldn't find item with name: \(name)."
            }
            logger.debug("Failed to find item. Due to server 404 error.")
        } catch {
            logger.error("Failed to find item with name: \(name). \(error)")
            errorMessage = error.localizedDescription
        }
    }
}
