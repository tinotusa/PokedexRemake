//
//  PokemonCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class PokemonCardViewModel: ObservableObject {
    @Published private(set) var pokemonSpecies: PokemonSpecies!
    @Published private(set) var types: Set<`Type`>!
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonCardViewModel")
}

extension PokemonCardViewModel {
    @MainActor
    func loadData(from pokemon: Pokemon) async {
        do {
            let id = pokemon.species.url.lastPathComponent
            async let pokemonSpecies = PokemonSpecies(id)
            async let types = getTypes(from: pokemon)
            
            self.pokemonSpecies = try await pokemonSpecies
            self.types = await types
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    private func getTypes(from pokemon: Pokemon) async -> Set<`Type`> {
        await withTaskGroup(of: `Type`?.self) { group in
            for pokemonType in pokemon.types {
                group.addTask { [weak self] in
                    do {
                        guard let name = pokemonType.type.name else {
                            self?.logger.debug("Failed to get type name.")
                            return nil
                        }
                        return try await `Type`(name)
                    } catch {
                        self?.logger.debug("Failed to get type.")
                    }
                    return nil
                }
            }
            
            var types = Set<`Type`>()
            for await type in group {
                guard let type else { continue }
                types.insert(type)
            }
            return types
        }
    }
}
