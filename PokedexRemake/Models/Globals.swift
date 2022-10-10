//
//  Globals.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI
import os
import SwiftUI

struct Globals {
    static func getTypes(urls: [URL]) async throws -> Set<`Type`> {
        try await withThrowingTaskGroup(of: `Type`.self) { group in
            for url in urls {
                group.addTask {
                    let id = url.lastPathComponent
                    return try await `Type`(id)
                }
            }
            var types = Set<`Type`>()
            for try await type in group {
                types.insert(type)
            }
            return types
        }
    }
    
    static func getGeneration(from pokemonSpecies: PokemonSpecies) async throws -> Generation {
        let id = pokemonSpecies.generation.url.lastPathComponent
        return try await Generation(id)
    }
    
    static func getPokemonSpecies(from pokemon: Pokemon) async throws -> PokemonSpecies {
        let id = pokemon.species.url.lastPathComponent
        return try await PokemonSpecies(id)
    }
    
    static func getMoves(urls: [URL]) async throws -> Set<Move> {
        try await withThrowingTaskGroup(of: Move.self) { group in
            for url in urls {
                group.addTask {
                    let id = url.lastPathComponent
                    return try await Move(id)
                }
            }
            
            var moves = Set<Move>()
            for try await move in group {
                moves.insert(move)
            }
            return moves
        }
    }
    
    
    static func formattedID(_ id: Int) -> String {
        String(format: "#%03d", id)
    }
    
    static func sortedTypes(_ types: Set<`Type`>) -> [`Type`] {
        types.sorted()
    }
}
