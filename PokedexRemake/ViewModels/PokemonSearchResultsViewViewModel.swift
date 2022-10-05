//
//  PokemonSearchResultsViewViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import os
import SwiftPokeAPI

final class PokemonSearchResultsViewViewModel: ObservableObject {
    @Published private(set) var pokemon: [Pokemon] = []
    @Published private(set) var pokemonSpecies: [PokemonSpecies] = []
    @Published private(set) var generations: [Generation] = []
    @Published private(set) var types: Set<`Type`> = []
    
    @Published private(set) var errorText: String?
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonSearchResultsViewViewModel")
    @Published private(set) var isSearchLoading = false
}

extension PokemonSearchResultsViewViewModel {
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
                
                var types = [`Type`]()
                for await type in group {
                    guard let type else { continue }
                    types.append(type)
                }
                
                return types
            }
            self.pokemon.insert(pokemon, at: 0)
            self.pokemonSpecies.append(pokemonSpecies)
            self.generations.append(generation)
            self.types.formUnion(types)
        } catch {
            logger.error("Failed to get pokemon with name: \(name). \(error)")
            withAnimation {
                errorText = "Couldn't find a pokemon with name: \(name)."
            }
        }
    }
    
    func getTypes(for pokemon: Pokemon) -> [`Type`] {
        let types = types.filter { type in
            for pokemonType in pokemon.types {
                if pokemonType.type.name == type.name {
                    return true
                }
            }
            return false
        }
        return types.sorted()
    }
    
    // TODO: use confirmation dialog here?
    @MainActor
    func clearRecentlySearched() {
        pokemon = []
    }
}
