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
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonDataStore")
    
    enum PokemonDataStoreError: Error {
        case speciesNotFound
        case typesNotFound
        case generationNotFound
    }
}

extension PokemonDataStore {
    func addPokemonData(_ pokemonData: PokemonData) {
        addPokemon(pokemonData.pokemon)
        addPokemonSpecies(pokemonData.pokemonSpecies)
        pokemonData.types.forEach(addType)
    }
    
    func addPokemon(_ pokemon: Pokemon) {
        self.pokemon.insert(pokemon)
    }
    
    func addPokemon(_ pokemon: [Pokemon]) {
        self.pokemon.formUnion(pokemon)
    }
    
    func addPokemonSpecies(_ pokemonSpecies: PokemonSpecies) {
        self.pokemonSpecies.insert(pokemonSpecies)
    }
    
    func addPokemonSpecies(_ pokemonSpecies: [PokemonSpecies]) {
        self.pokemonSpecies.formUnion(pokemonSpecies)
    }
    
    func addGeneration(_ generation: Generation) {
        self.generations.insert(generation)
    }
    
    func addGenerations(_ generations: [Generation]) {
        self.generations.formUnion(generations)
    }
    
    func addType(_ type: `Type`) {
        self.types.insert(type)
    }
    
    func addTypes(_ types: [`Type`]) {
        self.types.formUnion(types)
    }
}

// MARK: Getters
extension PokemonDataStore {
    func pokemonData(for pokemon: Pokemon) throws -> PokemonData {
        guard let pokemonSpecies = pokemonSpecies.first(where: { $0.name == pokemon.species.name } ) else {
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
            throw PokemonDataStoreError.typesNotFound
        }
        
        guard let generation = generations.first(where: { $0.name == pokemonSpecies.generation.name }) else {
            throw PokemonDataStoreError.generationNotFound
        }
        
        return PokemonData(
            pokemon: pokemon,
            pokemonSpecies: pokemonSpecies,
            types: Array(types),
            generation: generation
        )
    }
}

// MARK: Computed properties
extension PokemonDataStore {
    
}
