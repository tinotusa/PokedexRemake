//
//  PokemonSearchResultsViewViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import os
import SwiftPokeAPI

final class PokemonSearchResultsViewViewModel: ObservableObject {
    @Published private(set) var pokemon: [Pokemon] = []
    @Published private(set) var errorText: String?
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonSearchResultsViewViewModel")
}

extension PokemonSearchResultsViewViewModel {
    @MainActor
    func searchForPokemon(named name: String) async {
        do {
            let pokemon = try await Pokemon(name)
            self.pokemon.insert(pokemon, at: 0)
            withAnimation {
                errorText = nil
            }
        } catch {
            logger.error("Failed to get pokemon with name: \(name). \(error)")
            withAnimation {
                errorText = "Couldn't find a pokemon with name: \(name)."
            }
        }
    }
    
    @MainActor
    func clearRecentlySearched() {
        pokemon = []
    }
}
