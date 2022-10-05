//
//  PokemonCategoryViewViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class PokemonCategoryViewViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var pokemon = [Pokemon]()
    @Published private(set) var pokemonSpecies = [PokemonSpecies]()
    @Published private(set) var types = Set<`Type`>()
    
    private var logger = Logger(subsystem: "com.tinotusa.Pokedex", category: "PokemonCategoryViewViewModel")
    @Published private(set) var hasNextPage = true
    @Published private(set) var nextPageURL: URL? {
        didSet {
            if nextPageURL == nil {
                hasNextPage = false
            }
        }
    }
}

// MARK: - Public functions
extension PokemonCategoryViewViewModel {
    @MainActor
    func loadData() async {
        do {
            let pokemonResourceList = try await NamedAPIResourceList(.pokemon, limit: 20)
            nextPageURL = pokemonResourceList.next
            
            let pokemon = await getResources(from: pokemonResourceList)
            let pokemonSpecies = await getPokemonSpecies(from: pokemon)
            let types = await getTypes(from: pokemon)
            
            self.pokemon = pokemon
            self.pokemonSpecies = pokemonSpecies
            self.types = types
            
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func loadNextPage() async {
        logger.debug("Loading next page.")
        if !hasNextPage {
            logger.debug("Failed to load next page. View model doesn't have a next page.")
            return
        }
        guard let nextPageURL else {
            logger.debug("Failed to load next page. nextPageURL is nil.")
            return
        }
        do {
            let resourceList = try await NamedAPIResourceList(nextPageURL)
            self.nextPageURL = resourceList.next
            
            let pokemon = await getResources(from: resourceList)
            let pokemonSpecies = await getPokemonSpecies(from: pokemon)
            let types = await getTypes(from: pokemon)
            
            self.pokemon.append(contentsOf: pokemon)
            self.pokemonSpecies.append(contentsOf: pokemonSpecies)
            self.types.formUnion(types)
            logger.debug("Successfully loaded the next page. Loaded \(pokemon.count) pokemon.")
        } catch {
            logger.error("Failed to load next page. \(error)")
        }
    }
    
    func pokemonSpecies(for pokemon: Pokemon) -> PokemonSpecies? {
        self.pokemonSpecies.first { $0.name == pokemon.species.name }
    }
    
    func types(for pokemon: Pokemon) -> [`Type`] {
        self.types.filter { type in
            for pokemonType in pokemon.types {
                if pokemonType.type.name == type.name {
                    return true
                }
            }
            return false
        }
    }
}

// MARK: - Private functions
private extension PokemonCategoryViewViewModel {
    func getResources(from resourceList: NamedAPIResourceList) async -> [Pokemon] {
        let pokemon = await withTaskGroup(of: Pokemon?.self) { group in
            for resource in resourceList.results {
                group.addTask { [weak self] in
                    do {
                        guard let name = resource.name else {
                            return nil
                        }
                        return try await Pokemon(name)
                    } catch {
                        self?.logger.debug("Failed to get pokemon. \(error)")
                    }
                    return nil
                }
            }
            
            var tempPokemon = [Pokemon]()
            for await pokemon in group {
                guard let pokemon else { continue }
                tempPokemon.append(pokemon)
            }
            return tempPokemon
        }
        return pokemon.sorted()
    }
    
    func getPokemonSpecies(from pokemon: [Pokemon]) async -> [PokemonSpecies] {
        let pokemonSpecies = await withTaskGroup(of: PokemonSpecies?.self) { group in
            for pokemon in pokemon {
                group.addTask { [weak self] in
                    do {
                        guard let name = pokemon.species.name else {
                            return nil
                        }
                        return try await PokemonSpecies(name)
                    } catch {
                        self?.logger.debug("Failed to get PokemonSpecies. \(error)")
                    }
                    return nil
                }
            }
            
            var tempPokemonSpecies = [PokemonSpecies]()
            for await pokemonSpecies in group {
                guard let pokemonSpecies else { continue }
                tempPokemonSpecies.append(pokemonSpecies)
            }
            return tempPokemonSpecies
        }
        
        return pokemonSpecies
    }
    
    func getTypes(from pokemon: [Pokemon]) async -> Set<`Type`> {
        let types = await withTaskGroup(of: `Type`?.self) { group in
            for pokemon in pokemon {
                for type in pokemon.types {
                    group.addTask { [weak self] in
                        do {
                            guard let name = type.type.name else {
                                return nil
                            }
                            return try await `Type`(name)
                        } catch {
                            self?.logger.debug("Failed to get Type. \(error)")
                        }
                        return nil
                    }
                }
            }
            
            var tempTypes = Set<`Type`>()
            for await type in group {
                guard let type else { continue }
                tempTypes.insert(type)
            }
            return tempTypes
        }
        
        return types
    }
}
