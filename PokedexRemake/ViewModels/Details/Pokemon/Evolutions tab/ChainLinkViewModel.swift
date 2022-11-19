//
//  ChainLinkViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 8/10/2022.
//

import SwiftUI
import SwiftPokeAPI
import os

/// View model for ChainLinkView
final class ChainLinkViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The previous PokemonEvolution.
    @Published private(set) var evolvesFromPokemon: Pokemon?
    /// The current PokemonEvolution.
    @Published private(set) var pokemon: Pokemon?
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ChainLlinkViewModel")
    
    /// Errors for the ChainLink
    enum ChainLinkError: Error, LocalizedError {
        case noEvolvesFromSpecies(species: PokemonSpecies)
        
        var errorDescription: String? {
            switch self {
            case .noEvolvesFromSpecies(let species): return "Failed to get the evolves from species for the pokemon. species id: \(species.id)"
            }
        }
    }
}

extension ChainLinkViewModel {
    /// Loads the relevant data from the ChainLink.
    /// - Parameter chainLink: The ChainLink to load data from.
    @MainActor
    func loadData(chainLink: ChainLink) async {
        do {
            let pokemonSpecies = try await PokemonSpecies(chainLink.species.url)
            guard let evolvesFromSpecies = pokemonSpecies.evolvesFromSpecies else {
                logger.error("Failed to get evolves from species.")
                viewLoadingState = .error(error: ChainLinkError.noEvolvesFromSpecies(species: pokemonSpecies))
                return
            }
            let evolvesFromSpeciesID = evolvesFromSpecies.url.lastPathComponent
            let evolvesFromPokemonSpecies = try await PokemonSpecies(evolvesFromSpeciesID)
            
            async let evolvesFromPokemon = try Pokemon(evolvesFromPokemonSpecies.name)
            let pokemonSpeciesID = chainLink.species.url.lastPathComponent
            async let pokemon = try Pokemon(pokemonSpeciesID)
            
            self.evolvesFromPokemon = try await evolvesFromPokemon
            self.pokemon = try await pokemon
            
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to get evolves from pokemon species. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
