//
//  PokemonSpeciesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 2/11/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// Grouped information about a pokemon.
struct PokemonData: Identifiable {
    /// The id of the pokemon.
    var id: Int { pokemon.id }
    /// The pokemon.
    let pokemon: Pokemon
    /// The PokemonSpecies of the Pokemon.
    let pokemonSpecies: PokemonSpecies
}

/// View model for PokemonSpeciesListView.
final class PokemonSpeciesListViewModel: ObservableObject, Pageable {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The pokemon data array.
    @Published private(set) var pokemonDataArray = [PokemonData]()
    /// The current pages information.
    @Published private(set) var pageInfo = PageInfo()
    
    /// The URLs for the pokemon species.
    private var speciesURLs = [URL]()
    /// The URLs for the pokemon.
    private var pokemonURLS = [URL]()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonSpeciesListViewModel")
    
    /// Creates the view model.
    /// - Parameter pokemonSpeciesURLs: The URLs to load data from.
    init(pokemonSpeciesURLs: [URL]) {
        self.speciesURLs = pokemonSpeciesURLs.sorted(by: pokemonSpeciesURLSort)
        self.pokemonURLS = speciesURLs.map { URL(string: "https://pokeapi.co/api/v2/pokemon/\($0.lastPathComponent)")! }
    }
}

extension PokemonSpeciesListViewModel {
    @MainActor
    /// Fetches a page based on the current pageInfo.
    func loadPage() async {
        do {
            let pokemonDataArray = try await getPokemonSpecies().sorted { $0.pokemon.id < $1.pokemon.id }
            pageInfo.updateOffset()
            pageInfo.hasNextPage = pokemonDataArray.count == pageInfo.limit
            self.pokemonDataArray = pokemonDataArray
            
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
}

private extension PokemonSpeciesListViewModel {
    /// Returns true if the lhs URL is less than the rhs URL.
    /// - Parameters:
    ///   - lhs: The first URL.
    ///   - rhs: The second URL.
    /// - Returns: True if the lhs is less that the rhs.
    func pokemonSpeciesURLSort(lhs: URL, rhs: URL) -> Bool {
        if let id1 = Int(lhs.lastPathComponent),
           let id2 = Int(rhs.lastPathComponent) {
            return id1 < id2
        }
        return false
    }
    
    /// Returns an array of PokemonData.
    /// - Returns: An array of PokemonData.
    func getPokemonSpecies() async throws -> [PokemonData] {
        try await withThrowingTaskGroup(of: PokemonData.self) { group in
            for (i, _) in speciesURLs.enumerated() where i >= pageInfo.offset && i < pageInfo.offset + pageInfo.limit {
                group.addTask {
                    let pokemonSpecies = try await PokemonSpecies(self.speciesURLs[i])
                    let pokemon = try await Pokemon(self.pokemonURLS[i])
                    return PokemonData(pokemon: pokemon, pokemonSpecies: pokemonSpecies)
                }
            }
            var results = [PokemonData]()
            for try await item in group {
                results.append(item)
            }
            return results
        }
    }
}
