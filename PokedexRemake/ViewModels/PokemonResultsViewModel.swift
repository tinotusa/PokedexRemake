//
//  PokemonResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import os
import SwiftPokeAPI

final class PokemonResultsViewModel: ObservableObject, SearchResultsList {
    @Published var results: [Pokemon] = [] {
        didSet {
            do {
                try saveHistoryToDisk()
            } catch {
                logger.error("Failed to save history to disk. \(error)")
            }
        }
    }
    @Published private(set) var errorMessage: String?
    @Published var showingClearHistoryDialog = false
    @Published private(set) var isSearchLoading = false
    private(set) var emptyPlaceholderText = LocalizedStringKey("Search for a pokemon")
    
    @Published var showingClearPokemonConfirmationDialog = false
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    let saveFilename = "pokemonSearchResults"
    let fileIOManager = FileIOManager()
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonResultsViewViewModel")
}

extension PokemonResultsViewModel {
    @MainActor
    func loadData() {
        logger.debug("Loading data from disk.")
        do {
            self.results = try loadHistoryFromDisk()
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
    func search(_ name: String) async {
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
            if let pokemon = self.results.first(where: { $0.id == pokemon.id }) {
                logger.debug("Pokemon with id \(pokemon.id) is already in the list. moving it to top.")
                moveToTop(pokemon)
            } else {
                self.results.insert(pokemon, at: 0)
            }
        } catch {
            logger.error("Failed to get pokemon with name: \(name). \(error)")
            withAnimation {
                errorMessage = "Couldn't find a pokemon with name: \(name)."
            }
        }
    }
}
