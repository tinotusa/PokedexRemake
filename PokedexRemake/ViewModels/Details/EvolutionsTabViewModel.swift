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
    func loadData(pokemonSpecies: PokemonSpecies, pokemonDataStore: PokemonDataStore) async {
        logger.debug("Loading data.")
        do {
            let evolutionChain = try await getEvolutionChain(for: pokemonSpecies, pokemonDataStore: pokemonDataStore)
            pokemonDataStore.addEvolutionChain(evolutionChain)
            
            self.chainLinks = getChainLinks(from: evolutionChain)
            
            viewLoadingState = .loaded
            
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
        }
    }
}

// MARK: Private functions
private extension EvolutionsTabViewModel {
    func getEvolutionChain(for pokemonSpecies: PokemonSpecies, pokemonDataStore: PokemonDataStore) async throws -> EvolutionChain {
        guard let chainURL = pokemonSpecies.evolutionChain?.url else {
            logger.debug("Pokemon species with id: \(pokemonSpecies.id) has no evolution chain.")
            throw EvolutionsTabError.noChainLinkURL
        }
        guard let id = Int(chainURL.lastPathComponent) else {
            logger.error("Failed to get id from chain url: \(chainURL).")
            throw EvolutionsTabError.failedToGetID
        }
        if let evolutionChain = pokemonDataStore.evolutionChains.first(where: { $0.id == id }) {
            logger.debug("Returning evolution chain from data store.")
            return evolutionChain
        }
        return try await EvolutionChain(id)
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
}
