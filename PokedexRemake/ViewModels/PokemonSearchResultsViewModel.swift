//
//  PokemonSearchResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import os
import SwiftPokeAPI

final class PokemonSearchResultsViewModel: ObservableObject {
    @Published private(set) var pokemon: [Pokemon] = []
    @Published private(set) var errorText: String?
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonSearchResultsViewViewModel")
    @Published private(set) var isSearchLoading = false
}

extension PokemonSearchResultsViewModel {
    @MainActor
    func searchForPokemon(named name: String) async {
        withAnimation {
            isSearchLoading = true
        }
        
        defer {
            withAnimation {
                isSearchLoading = false
            }
        }
        withAnimation {
            errorText = nil
        }

//        if let id = pokemon.first(where: { $0.name == PokeAPI.filteredName(name) }) {
//            moveIDToTop(pokemon.id)
//            logger.debug("Pokemon is already in the data store.")
//            return
//        }
        
        do {
            let pokemon = try await Pokemon(name)
//            let pokemonSpecies = try await Globals.getPokemonSpecies(from: pokemon)
            
//            let generation = try await Globals.getGeneration(from: pokemonSpecies)
//            let types = try await Globals.getTypes(urls: pokemon.types.map { $0.type.url })

            self.pokemon.insert(pokemon, at: 0)
        } catch {
            logger.error("Failed to get pokemon with name: \(name). \(error)")
            withAnimation {
                errorText = "Couldn't find a pokemon with name: \(name)."
            }
        }
    }
    
    func moveIDToTop(_ id: Int) {
        guard let index = pokemon.firstIndex(where: { $0.id == id }) else {
            logger.error("Failed to find index for pokemon id: \(id)")
            return
        }
        pokemon.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
    }
    
    // TODO: use confirmation dialog here?
    @MainActor
    func clearPokemon() {
        pokemon = []
    }
}
