//
//  PokemonDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 23/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var pokemonSpecies: PokemonSpecies!
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published var showingMovesSheet = false
    @Published var showingAbiltiesSheet = false
    private var logger = Logger(subsystem: "com.tinotusa.Pokedex", category: "PokemonDetailViewModel")
    
    @MainActor
    func loadData(from pokemon: Pokemon) async {
        do {
            self.pokemonSpecies = try await PokemonSpecies(pokemon.species.url)
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to get pokemon species from pokemon with id: \(pokemon.id)")
            viewLoadingState = .error(error: error)
        }
    }
}
