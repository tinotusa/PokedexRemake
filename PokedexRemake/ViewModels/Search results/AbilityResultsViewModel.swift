//
//  AbilityResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

final class AbilityResultsViewModel: ObservableObject, SearchResultsList {
    @Published private(set) var results = [Ability]() {
        didSet {
            saveHistoryToDisk()
        }
    }
    @Published private(set) var isSearchLoading = false
    @Published private(set) var errorMessage: String?
    private(set) var emptyPlaceholderText: LocalizedStringKey = "Search for an Ability."
    
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published var showingClearHistoryDialog = false
    
    private let fileIOManager = FileIOManager()
    static let saveFilename = "abilityResults"
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityResultsViewModel")
}

extension AbilityResultsViewModel {
    /// Loads the abilities search history from disk.
    @MainActor
    func loadData() {
        do {
            self.results = try fileIOManager.load([Ability].self, filename: Self.saveFilename)
            viewLoadingState = .loaded
        } catch CocoaError.fileReadNoSuchFile {
            logger.error("Failed to load history from disk. File doesn't exit.")
            viewLoadingState = .loaded
        }  catch {
            logger.error("Failed to load data from disk. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    /// Searches PokeAPI for an Ability with the given name or id.
    /// - parameter name: The name or id of the Ability.
    @MainActor
    func search(_ name: String) async {
        isSearchLoading = true
        errorMessage = nil
        defer {
            isSearchLoading = false
        }
        logger.debug("Searching for an ability with name: \(name).")
        do {
            let ability = try await Ability(name)
            let moved = results.moveToTop(ability)
            if !moved {
                self.results.insert(ability, at: 0)
            }
            logger.debug("Successfully loaded ability with name: \(name).")
        } catch {
            logger.error("Failed to find ability with name: \(name).")
            errorMessage = "Failed to find ability with name: \(name)."
        }
    }
    
    /// Saves the abilties search history to disk.
    func saveHistoryToDisk() {
        do {
            try fileIOManager.write(self.results, filename: Self.saveFilename)
        } catch {
            logger.error("Failed to write abilities search history to disk. \(error)")
        }
    }
    
    /// Moves the ability to index 0.
    /// - parameter ability: The ability to move.
    func moveToTop(_ ability: Ability) {
        let moved = self.results.moveToTop(ability)
        if !moved {
            logger.error("Failed to move ability \(ability.id) to index 0.")
        }
    }

    /// Clears the search history and deletes the history on disk.
    func clearHistory() {
        do {
            try fileIOManager.delete(Self.saveFilename)
            self.results = []
        } catch {
            logger.error("Failed to delete file name: \(Self.saveFilename). \(error)")
        }
    }
}
