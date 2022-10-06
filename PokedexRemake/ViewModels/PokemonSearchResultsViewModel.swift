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
    @Published private(set) var recentlySearched: [Int] = []
    @Published private(set) var errorText: String?
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonSearchResultsViewViewModel")
    @Published private(set) var isSearchLoading = false
}

extension PokemonSearchResultsViewModel {
    @MainActor
    func searchForPokemon(named name: String, pokemonDataStore: PokemonDataStore) async {
        withAnimation {
            isSearchLoading = true
        }
        
        defer {
            withAnimation {
                isSearchLoading = false
            }
        }
        withAnimation {
            errorText = nil
        }
        do {
            let pokemon = try await Pokemon(name)
            guard let speciesName = pokemon.species.name else {
                errorText = "Failed to find pokemon species with name: \(name)."
                return
            }
            let pokemonSpecies = try await PokemonSpecies(speciesName)
            
            guard let generationName = pokemonSpecies.generation.name else {
                errorText = "Failed to find generation from pokemon species with name: \(pokemonSpecies.name)."
                return
            }
            let generation = try await Generation(generationName)
            let types = await withTaskGroup(of: `Type`?.self) { group in
                for type in pokemon.types {
                    group.addTask { [weak self] in
                        do {
                            guard let name = type.type.name else { return nil }
                            return try await Type(name)
                        } catch {
                            self?.logger.error("Failed to get type from name:")
                        }
                        return nil
                    }
                }
                
                var types = Set<`Type`>()
                for await type in group {
                    guard let type else { continue }
                    types.insert(type)
                }
                
                return types
            }
            pokemonDataStore.addPokemon(pokemon)
            pokemonDataStore.addPokemonSpecies(pokemonSpecies)
            pokemonDataStore.addGeneration(generation)
            pokemonDataStore.addTypes(types)
        } catch {
            logger.error("Failed to get pokemon with name: \(name). \(error)")
            withAnimation {
                errorText = "Couldn't find a pokemon with name: \(name)."
            }
        }
    }
    
    // TODO: use confirmation dialog here?
    @MainActor
    func clearRecentlySearched() {
        recentlySearched = []
    }
}
