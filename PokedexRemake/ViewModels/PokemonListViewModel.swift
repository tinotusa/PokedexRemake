//
//  PokemonListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

#warning("last here")
// TODO: Use pagination protocol? (can i think of something better?)
// TODO: look into using a generic list view and keeping the view models as loaders?

/// View model for PokemonList.
final class PokemonListViewModel: ObservableObject, Identifiable  {
    let id = UUID().uuidString
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The pokemon urls to fetch Pokemon from.
    @Published private var urls = [URL]()
    /// The Pokemon for the list.
    @Published private(set) var pokemon = [Pokemon]()
    @Published private(set) var hasNextPage = true
    private var page = 0 {
        didSet {
            offset = page * limit
        }
    }
    private var limit = 20
    private var offset = 0
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonListViewModel")
}

extension PokemonListViewModel: Hashable {
    static func == (lhs: PokemonListViewModel, rhs: PokemonListViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension PokemonListViewModel {
    @MainActor
    func loadData(urls: [URL]) async {
        self.urls = urls
        do {
            let pokemon = try await Globals.getItems(Pokemon.self, urls: urls)
            if pokemon.count < limit {
                hasNextPage = false
            }
            self.pokemon = pokemon.sorted()
            page += 1
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func loadNextPage() async {
        logger.debug("Loading next page.")
        do {
            let newPokemon = try await Globals.getItems(Pokemon.self, urls: urls, limit: limit, offset: offset)
            if newPokemon.count < limit {
                hasNextPage = false
            }
            self.pokemon.append(contentsOf: newPokemon)
            page += 1
        } catch {
            logger.error("Failed to load next pokemon page. \(error)")
        }
    }
}
