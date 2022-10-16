//
//  PokemonSearchResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import os
import SwiftPokeAPI

final class PokemonSearchResultsViewModel: ObservableObject {
    @Published private(set) var pokemon: [Pokemon] = [] {
        didSet {
            save()
        }
    }
    @Published private(set) var errorMessage: String?
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonSearchResultsViewViewModel")
    @Published private(set) var isSearchLoading = false
    @Published var showingClearPokemonConfirmationDialog = false
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
}

extension PokemonSearchResultsViewModel {
    @MainActor
    func loadData() {
        self.pokemon = load()
        viewLoadingState = .loaded
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
            if let foundPokemon = self.pokemon.first(where: { $0.id == pokemon.id }) {
                logger.debug("Pokemon with id \(foundPokemon.id) is already in the list. moving it to top.")
                moveIDToTop(foundPokemon.id)
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
    
    func moveIDToTop(_ id: Int) {
        guard let index = pokemon.firstIndex(where: { $0.id == id }) else {
            logger.error("Failed to find index for pokemon id: \(id)")
            return
        }
        pokemon.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
    }
    
    @MainActor
    func clearPokemon() {
        pokemon = []
    }
}

private extension PokemonSearchResultsViewModel {
    static let saveFileName = "pokemonSearchResults"
    
    func load() -> [Pokemon] {
        let documentsURL = FileManager.default.documentsURL()
        let saveFileURL = documentsURL.appendingPathComponent(Self.saveFileName)
        do {
            let data = try Data(contentsOf: saveFileURL)
            return try JSONDecoder().decode([Pokemon].self, from: data)
        } catch {
            logger.error("Failed to load data from save file. \(error)")
        }
        return []
    }
    
    func save() {
        let documentsURL = FileManager.default.documentsURL()
        let saveFileURL = documentsURL.appendingPathComponent(Self.saveFileName)
        do {
            let data = try JSONEncoder().encode(pokemon)
            try data.write(to: saveFileURL, options: [.atomic, .completeFileProtection])
        } catch {
            logger.error("Failed to save pokemon results to disk. \(error)")
        }
    }
}
// TODO: Move me
extension FileManager {
    func documentsURL() -> URL {
        self.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
