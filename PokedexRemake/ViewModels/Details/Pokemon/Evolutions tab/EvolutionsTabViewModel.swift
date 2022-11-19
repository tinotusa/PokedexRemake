//
//  EvolutionsTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for EvolutionsTab.
final class EvolutionsTabViewModel: ObservableObject {
    /// The pokemon's evolution chain links.
    @Published private(set) var chainLinks = [ChainLink]()
    /// The loading state for the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "EvolutionsTabViewModel")
    
    /// Errors for the EvolutionsTab
    enum EvolutionsTabError: Error {
        case noChainLinkURL
        case failedToGetID
    }
}

// MARK: Public functions
extension EvolutionsTabViewModel {
    /// Loads the relevant data from the given Pokemon.
    /// - Parameter pokemon: The Pokemon to load data from.
    @MainActor
    func loadData(pokemon: Pokemon) async {
        logger.debug("Loading data.")
        do {
            let pokemonSpecies = try await PokemonSpecies(pokemon.species.url)
            let evolutionChain = try await getEvolutionChain(for: pokemonSpecies)
            
            self.chainLinks = getChainLinks(from: evolutionChain)
            
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
    /// Returns the EvolutionChain for the PokemonSpecies.
    /// - Parameter pokemonSpecies: The PokemonSpecies to get the EvolutionChain from.
    /// - Returns: An EvolutionChain.
    func getEvolutionChain(for pokemonSpecies: PokemonSpecies) async throws -> EvolutionChain {
        guard let chainURL = pokemonSpecies.evolutionChain?.url else {
            logger.debug("Pokemon species with id: \(pokemonSpecies.id) has no evolution chain.")
            throw EvolutionsTabError.noChainLinkURL
        }
        return try await EvolutionChain(chainURL)
    }
    
    /// Returns the ChainLinks for the Pokemon's evolution.
    /// - Parameter evolutionChain: The EvolutionChain to get the ChainLinks from.
    /// - Returns: An array of ChainLinks representing the Pokemon's evolutions.
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
