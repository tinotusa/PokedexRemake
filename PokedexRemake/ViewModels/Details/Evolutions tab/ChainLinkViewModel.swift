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
    func loadData(chainLink: ChainLink) async {
        do {
            let id = chainLink.species.url.lastPathComponent
            let pokemonSpecies = try await PokemonSpecies(id)
            guard let evolvesFromSpecies = pokemonSpecies.evolvesFromSpecies else {
                logger.error("Failed to get evolves from species.")
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
