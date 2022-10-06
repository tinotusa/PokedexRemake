//
//  PokemonDataStore.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

final class PokemonDataStore: ObservableObject {
    @Published private(set) var pokemon: Set<Pokemon> = []
    @Published private(set) var pokemonSpecies: Set<PokemonSpecies> = []
    @Published private(set) var generations: Set<Generation> = []
    @Published private(set) var types: Set<`Type`> = []
    @Published private(set) var versions: Set<Version> = []
    @Published private(set) var items = Set<Item>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonDataStore")
    
    enum PokemonDataStoreError: Error {
        case speciesNotFound
        case typesNotFound
        case generationNotFound
    }
}

extension PokemonDataStore {
    @MainActor
    func addPokemon(_ pokemon: Set<Pokemon>) {
        self.pokemon.formUnion(pokemon)
    }
//
    @MainActor
    func addPokemon(_ pokemon: Pokemon) {
        self.pokemon.insert(pokemon)
    }
    
    @MainActor
    func addPokemonSpecies(_ pokemonSpecies: Set<PokemonSpecies>) {
        self.pokemonSpecies.formUnion(pokemonSpecies)
    }
    
    @MainActor
    func addPokemonSpecies(_ pokemonSpecies: PokemonSpecies) {
        self.pokemonSpecies.insert(pokemonSpecies)
    }
    
    @MainActor
    func addGenerations(_ generations: Set<Generation>) {
        self.generations.formUnion(generations)
    }
    
    @MainActor
    func addGeneration(_ generation: Generation) {
        self.generations.insert(generation)
    }
    
    @MainActor
    func addTypes(_ types: Set<`Type`>) {
        self.types.formUnion(types)
    }
    
    @MainActor
    func addType(_ type: `Type`) {
        self.types.insert(type)
    }
    
    @MainActor
    func addVersions(_ versions: Set<Version>) {
        self.versions.formUnion(versions)
    }
    
    @MainActor
    func addItems(_ items: Set<Item>) {
        self.items.formUnion(items)
    }
}

// MARK: Getters
extension PokemonDataStore {
    func pokemonData(for pokemon: Pokemon) throws -> PokemonData {
        guard let pokemonSpecies = pokemonSpecies.first(where: { $0.name == pokemon.species.name } ) else {
            logger.error("Species not found for \(pokemon.name).")
            throw PokemonDataStoreError.speciesNotFound
        }
        
        let types = types.filter { type in
            for pokemonType in pokemon.types {
                if pokemonType.type.name == type.name {
                    return true
                }
            }
            return false
        }
        
        guard types.count > 0 else {
            logger.error("Types not found for \(pokemon.name).")
            throw PokemonDataStoreError.typesNotFound
        }
        
        let generation = generations.first(where: { $0.name == pokemonSpecies.generation.name })
        
        return PokemonData(
            pokemon: pokemon,
            pokemonSpecies: pokemonSpecies,
            types: Array(types),
            generation: generation
        )
    }
    
    func items(for pokemon: Pokemon) -> Set<Item> {
        self.items.filter { item in
            for heldItem in pokemon.heldItems {
                if heldItem.item.name == item.name {
                    return true
                }
            }
            return false
        }
    }
}

// MARK: Computed properties
extension PokemonDataStore {
    
}
