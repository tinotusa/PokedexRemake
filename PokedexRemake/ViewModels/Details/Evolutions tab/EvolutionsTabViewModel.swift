//
//  EvolutionsTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class EvolutionsTabViewModel: ObservableObject {
//    @Published private(set) var pokemonSpecies: PokemonSpecies!
    @Published private(set) var chainLinks = [ChainLink]()
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "EvolutionsTabViewModel")
    
    enum EvolutionsTabError: Error {
        case noChainLinkURL
        case failedToGetID
    }
}

// MARK: Public functions
extension EvolutionsTabViewModel {
    @MainActor
    func loadData(pokemon: Pokemon) async {
        logger.debug("Loading data.")
        do {
            let pokemonSpecies = try await Globals.getPokemonSpecies(from: pokemon)
            let evolutionChain = try await getEvolutionChain(for: pokemonSpecies)
            
            self.chainLinks = getChainLinks(from: evolutionChain)
//            let pokemonSpecies = await getPokemonSpecies(for: chainLinks)
            
            viewLoadingState = .loaded
            
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}

// MARK: Private functions
private extension EvolutionsTabViewModel {
    func getEvolutionChain(for pokemonSpecies: PokemonSpecies) async throws -> EvolutionChain {
        guard let chainURL = pokemonSpecies.evolutionChain?.url else {
            logger.debug("Pokemon species with id: \(pokemonSpecies.id) has no evolution chain.")
            throw EvolutionsTabError.noChainLinkURL
        }
        return try await EvolutionChain(chainURL)
    }
    
    func getChainLinks(from evolutionChain: EvolutionChain) -> [ChainLink] {
        var chainLinks = [ChainLink]()
        var queue = [ChainLink]()
        
        queue.append(evolutionChain.chain)
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            chainLinks.append(current)
            queue.append(contentsOf: current.evolvesTo)
        }
        return chainLinks
    }
    
    func getPokemonSpecies(for chainLinks: [ChainLink]) async -> Set<PokemonSpecies> {
        await withTaskGroup(of: PokemonSpecies?.self) { group in
            for chainLink in chainLinks {
                group.addTask { [weak self] in
                    do {
                        guard let speciesName = chainLink.species.name else {
                            self?.logger.debug("Failed to get species name from chain link. \(chainLink.species.url)")
                            return nil
                        }
                        return try await PokemonSpecies(speciesName)
                    } catch {
                        self?.logger.error("Failed to get pokemon species. \(error)")
                    }
                    return nil
                }
            }
            var pokemonSpeciesSet = Set<PokemonSpecies>()
            for await pokemonSpecies in group {
                guard let pokemonSpecies else { continue }
                pokemonSpeciesSet.insert(pokemonSpecies)
            }
            return pokemonSpeciesSet
        }
    }
    
    func getPokemon(from pokemonSpeciesArray: Set<PokemonSpecies>) async -> Set<Pokemon> {
        await withTaskGroup(of: Pokemon?.self) { group in
            for pokemonSpecies in pokemonSpeciesArray {
                group.addTask { [weak self] in
                    do {
                        return try await Pokemon(pokemonSpecies.name)
                    } catch {
                        self?.logger.error("Failed to get pokemon. \(error)")
                    }
                    return nil
                }
            }
            var pokemonSet = Set<Pokemon>()
            for await pokemon in group {
                guard let pokemon else { continue }
                pokemonSet.insert(pokemon)
            }
            return pokemonSet
        }
    }
}
