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


final class MoveResultsViewModel: ObservableObject, SearchResultsList {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var results = [Move]() {
        didSet {
            saveToDisk()
        }
    }
    @Published var showingClearHistoryDialog = false
    @Published private(set) var isSearchLoading = false
    @Published private(set) var errorMessage: String?
    private(set) var emptyPlaceholderText: LocalizedStringKey = "Search for a move."
    
    static let saveFilename = "moveResults"
    private let fileIOManager = FileIOManager()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveResultsViewModel")
}

extension MoveResultsViewModel {
    @MainActor
    func loadData() {
        do {
            self.results = try loadFromDisk()
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
        logger.debug("Searching for move with name: \(name).")
        if name.isEmpty {
            logger.debug("Search text is empty.")
            return
        }
        errorMessage = nil
        isSearchLoading = true
        defer { isSearchLoading = false }
        
        do {
            let move = try await Move(name)
            if self.results.contains(move) {
                moveToTop(move)
                logger.debug("Move already in history. Moving it to top.")
                return
            }
            self.results.insert(move, at: 0)
            logger.debug("Successfully found move.")
        } catch PokeAPIError.invalidServerResponse(let code) where code == 404 {
            if let id = Int(name) {
                errorMessage = "Couldn't find move with id: \(id)."
            } else {
                errorMessage = "Couldn't find move with name: \(name)."
            }
            logger.debug("Failed to find move. Due to server 404 error.")
        } catch {
            logger.error("Failed to find move with name: \(name). \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func clearHistory() {
        do {
            try fileIOManager.delete(Self.saveFilename)
            self.results = []
            logger.debug("Cleared move search history.")
        } catch {
            logger.error("Failed to clear history. \(error)")
        }
    }
    
    func moveToTop(_ move: Move) {
        let moved = self.results.moveToTop(move)
        if !moved {
            logger.error("Failed to move move \(move.id) to top.")
        }
    }
}

private extension MoveResultsViewModel {
    func loadFromDisk() throws -> [Move] {
        try fileIOManager.load([Move].self, filename: Self.saveFilename)
    }
    
    func saveToDisk() {
        logger.debug("Saving data to disk.")
        do {
            try fileIOManager.write(self.results, filename: Self.saveFilename)
            logger.debug("Successfully saved data to disk.")
        } catch {
            logger.error("Failed to save to disk. \(error)")
        }
    }
}
