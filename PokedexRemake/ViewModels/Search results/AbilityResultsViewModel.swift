//
//  AbilityResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class AbilityResultsViewModel: ObservableObject {
    @Published private(set) var abilities = [Ability]() {
        didSet {
            saveHistoryToDisk()
        }
    }
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let fileIOManager = FileIOManager()
    private static let saveFilename = "abilityResults"
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityResultsViewModel")
}

extension AbilityResultsViewModel {
    /// Loads the abilities search history from disk.
    @MainActor
    func loadData() {
        do {
            self.abilities = try fileIOManager.load([Ability].self, documentName: Self.saveFilename)
            viewLoadingState = .loading
        } catch {
            logger.error("Failed to load data from disk. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    /// Searches PokeAPI for an Ability with the given name or id.
    /// - parameter name: The name or id of the Ability.
    @MainActor
    func search(_ name: String) async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }
        logger.debug("Searching for an ability with name: \(name).")
        do {
            let ability = try await Ability(name)
            let moved = abilities.moveToTop(ability)
            if !moved {
                self.abilities.insert(ability, at: 0)
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
            try fileIOManager.write(self.abilities, documentName: Self.saveFilename)
        } catch {
            logger.error("Failed to write abilities search history to disk. \(error)")
        }
    }
    
    /// Moves the ability to index 0.
    /// - parameter ability: The ability to move.
    func moveAbilityToTop(_ ability: Ability) {
        let moved = self.abilities.moveToTop(ability)
        if !moved {
            logger.error("Failed to move ability \(ability.id) to index 0.")
        }
    }
}
