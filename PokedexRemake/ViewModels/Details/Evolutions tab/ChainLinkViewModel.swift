//
//  ChainLinkViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 8/10/2022.
//

import SwiftUI
import SwiftPokeAPI
import os

final class ChainLinkViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    // TODO: remove force unwraps
    @Published private(set) var evolvesFromPokemon: Pokemon!
    @Published private(set) var pokemon: Pokemon!
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ChainLlinkViewModel")
}

extension ChainLinkViewModel {
    @MainActor
    func loadData(chainLink: ChainLink, pokemonDataStore: PokemonDataStore) async {
        guard let speciesName = chainLink.species.name else {
            logger.error("Failed to get pokemon species name from chain link.")
            return
        }
        do {
            let pokemonSpecies = try await PokemonSpecies(speciesName)
            guard let evolvesFromSpeciesName = pokemonSpecies.evolvesFromSpecies?.name else {
                logger.error("Failed to get evolves from pokemon species name from pokemon species.")
                return
            }
            guard let pokemonSpeciesName = chainLink.species.name else {
                logger.error("Failed to get pokemon species name.")
                return
            }
            let evolvesFromPokemonSpecies = try await PokemonSpecies(evolvesFromSpeciesName)
            
            async let evolvesFromPokemon = try Pokemon(evolvesFromPokemonSpecies.name)
            async let pokemon = try Pokemon(pokemonSpeciesName)
            
            self.evolvesFromPokemon = try await evolvesFromPokemon
            self.pokemon = try await pokemon
            
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to get evolves from pokemon species. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
