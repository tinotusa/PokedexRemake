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
    @Published private(set) var stats = Set<Stat>()
    @Published private(set) var evolutionChains = Set<EvolutionChain>()
    
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
    
    @MainActor
    func addStats(_ stats: Set<Stat>) {
        self.stats.formUnion(stats)
    }
    
    @MainActor
    func addEvolutionChain(_ chain: EvolutionChain) {
        self.evolutionChains.insert(chain)
    }
}

// MARK: Getters
extension PokemonDataStore {
    func pokemon(ids: [Int]) -> [Pokemon] {
        let filteredPokemon = pokemon.filter { pokemon in
            for id in ids {
                if id == pokemon.id {
                    return true
                }
            }
            return true
        }
        var correctedOrder = [Pokemon]()
        for id in ids {
            guard let pokemon = filteredPokemon.first(where: { $0.id == id } ) else {
                continue
            }
            correctedOrder.append(pokemon)
        }
        return correctedOrder
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
    
    func stats(for pokemon: Pokemon) -> Set<Stat> {
        stats.filter { stat in
            for pokemonStat in pokemon.stats {
                guard let name = pokemonStat.stat.name else {
                    continue
                }
                if stat.name == name {
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
