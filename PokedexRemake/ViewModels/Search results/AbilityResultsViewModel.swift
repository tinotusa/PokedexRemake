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
    @Published var results = [Ability]() {
        didSet {
            do {
                try saveHistoryToDisk()
            } catch {
                logger.error("Failed to save history to disk. \(error)")
            }
        }
    }
    @Published private(set) var isSearchLoading = false
    @Published private(set) var errorMessage: String?
    private(set) var emptyPlaceholderText: LocalizedStringKey = "Search for an Ability."
    
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published var showingClearHistoryDialog = false
    
    let fileIOManager = FileIOManager()
    let saveFilename = "abilityResults"
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityResultsViewModel")
}

extension AbilityResultsViewModel {
    /// Loads the abilities search history from disk.
    @MainActor
    func loadData() {
        do {
            self.results = try loadHistoryFromDisk()
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
            let moved = moveToTop(ability)
            if !moved {
                self.results.insert(ability, at: 0)
            }
            logger.debug("Successfully loaded ability with name: \(name).")
        } catch {
            logger.error("Failed to find ability with name: \(name).")
            errorMessage = "Failed to find ability with name: \(name)."
        }
    }
}
