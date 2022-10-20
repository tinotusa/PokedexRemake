//
//  PokemonListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class PokemonListViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private var urls = [URL]()
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

extension PokemonListViewModel {
    @MainActor
    func loadData(urls: [URL]) async {
        self.urls = urls
        do {
            let pokemon = try await getPokemon(urls: urls)
            if pokemon.count < limit {
                hasNextPage = false
            }
            self.pokemon = pokemon
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
            let newPokemon = try await getNextPokemonPage()
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

private extension PokemonListViewModel {
    func getPokemon(urls: [URL]) async throws -> [Pokemon] {
        try await withThrowingTaskGroup(of: Pokemon.self) { group in
            for (i, url) in urls.enumerated() where i < limit {
                group.addTask {
                    return try await Pokemon(url)
                }
            }
            
            var pokemonArray = [Pokemon]()
            for try await pokemon in group {
                pokemonArray.append(pokemon)
            }
            return pokemonArray
        }
    }
    
    func getNextPokemonPage() async throws -> [Pokemon] {
        try await withThrowingTaskGroup(of: Pokemon.self) { group in
            for (i, url) in urls.enumerated() where i > offset && i < offset + limit {
                group.addTask {
                    return try await Pokemon(url)
                }
            }
            var pokemonArray = [Pokemon]()
            for try await pokemon in group {
                pokemonArray.append(pokemon)
            }
            return pokemonArray
        }
    }
}
