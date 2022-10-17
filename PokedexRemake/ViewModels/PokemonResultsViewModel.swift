//
//  PokemonResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import os
import SwiftPokeAPI

final class PokemonResultsViewModel: ObservableObject {
    @Published private(set) var pokemon: [Pokemon] = [] {
        didSet {
            saveToDisk()
        }
    }
    @Published private(set) var errorMessage: String?
    @Published private(set) var isSearchLoading = false
    @Published var showingClearPokemonConfirmationDialog = false
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    static let saveFileName = "pokemonSearchResults"
    private let fileIOManager = FileIOManager()
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonResultsViewViewModel")
}

extension PokemonResultsViewModel {
    @MainActor
    func loadData() {
        logger.debug("Loading data from disk.")
        do {
            self.pokemon = try fileIOManager.load([Pokemon].self, documentName: Self.saveFileName)
            logger.debug("Successfully loaded data from disk.")
            viewLoadingState = .loaded
        } catch CocoaError.fileReadNoSuchFile {
            logger.debug("History file couldn't be read.")
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to load from disk")
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func searchForPokemon(named name: String) async {
        withAnimation {
            isSearchLoading = true
        }
        
        defer {
            withAnimation {
                isSearchLoading = false
            }
        }
        withAnimation {
            errorMessage = nil
        }
        
        do {
            let pokemon = try await Pokemon(name)
            if let pokemon = self.pokemon.first(where: { $0.id == pokemon.id }) {
                logger.debug("Pokemon with id \(pokemon.id) is already in the list. moving it to top.")
                moveToTop(pokemon)
            } else {
                self.pokemon.insert(pokemon, at: 0)
            }
        } catch {
            logger.error("Failed to get pokemon with name: \(name). \(error)")
            withAnimation {
                errorMessage = "Couldn't find a pokemon with name: \(name)."
            }
        }
    }
    
    func moveToTop(_ pokemon: Pokemon) {
        let hasMoved = self.pokemon.moveToTop(pokemon)
        if !hasMoved {
            logger.error("Failed to move pokemon \(pokemon.id) to index 0.")
        }
    }
    
    /// Clears the pokemon search history and removes the history file from disk.
    @MainActor
    func clearHistory() {
        do {
            try fileIOManager.delete(Self.saveFileName)
            pokemon = []
            logger.debug("Successfully cleared search history.")
        } catch {
            logger.error("Failed to clear search history. \(error)")
        }
    }
}

private extension PokemonResultsViewModel {
    func saveToDisk() {
        logger.debug("Saving pokemon results to disk.")
        do {
            try fileIOManager.write(self.pokemon, documentName: Self.saveFileName)
            logger.debug("Successfully saved pokemon results to disk.")
        } catch {
            logger.error("Failed to save to disk. \(error)")
        }
    }
}
// TODO: Move me
extension FileManager {
    func documentsURL() -> URL {
        self.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
