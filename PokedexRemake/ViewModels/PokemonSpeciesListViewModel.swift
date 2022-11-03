//
//  PokemonSpeciesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 2/11/2022.
//

import Foundation
import SwiftPokeAPI
import os

struct PokemonGroup: Identifiable {
    var id: Int { pokemon.id }
    let pokemon: Pokemon
    let pokemonSpecies: PokemonSpecies
}

final class PokemonSpeciesListViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var pokemonGroup = [PokemonGroup]() {
        didSet {
            if abs(pokemonGroup.count - oldValue.count) < limit {
                hasNextPage = false
            }
        }
    }
    
    @Published private(set) var hasNextPage = true
    private var isLoading = false
    private var limit = 20
    private var offset = 0
    private var page = 0 {
        didSet {
             offset = page * limit
        }
    }
    
    private var urls = [URL]()
    private var pokemonURLS = [URL]()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonSpeciesListViewModel")
}

extension PokemonSpeciesListViewModel {
    @MainActor
    func loadData(speciesURL: [URL]) async {
        do {
            self.urls = speciesURL.sorted(by: pokemonSpeciesURLSort)
            self.pokemonURLS = urls.map { URL(string: "https://pokeapi.co/api/v2/pokemon/\($0.lastPathComponent)")! }

            let pokemonGroup = try await getPokemonSpecies().sorted { $0.pokemon.id < $1.pokemon.id }
            self.pokemonGroup = pokemonGroup
            
            page += 1
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func getNextPage() async {
        if !hasNextPage { return }
        if isLoading { return }
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let pokemonGroup = try await getPokemonSpecies(offset: offset).sorted { $0.pokemon.id < $1.pokemon.id }
            self.pokemonGroup.append(contentsOf: pokemonGroup)
            page += 1
        } catch {
            logger.error("Failed to get next page. \(error)")
        }
    }
}

private extension PokemonSpeciesListViewModel {
    func pokemonSpeciesURLSort(lhs: URL, rhs: URL) -> Bool {
        if let id1 = Int(lhs.lastPathComponent),
           let id2 = Int(rhs.lastPathComponent) {
            return id1 < id2
        }
        return false
    }

    func getPokemonSpecies(limit: Int = 20, offset: Int = 0) async throws -> [PokemonGroup] {
        try await withThrowingTaskGroup(of: PokemonGroup.self) { group in
            for (i, _) in urls.enumerated() where i >= offset && i < offset + limit {
                group.addTask {
                    let pokemonSpecies = try await PokemonSpecies(self.urls[i])
                    let pokemon = try await Pokemon(self.pokemonURLS[i])
                    return PokemonGroup(pokemon: pokemon, pokemonSpecies: pokemonSpecies)
                }
            }
            var results = [PokemonGroup]()
            for try await item in group {
                results.append(item)
            }
            return results
        }
    }
}
