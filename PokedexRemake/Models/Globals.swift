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

/// A struct that holds functions that are used throughout the app.
struct Globals {
    /// Gets a Generation from a PokemonSpecies.
    /// - Parameter pokemonSpecies: The PokemonSpecies to get the Generation from.
    /// - Returns: The Generation for the PokemonSpecies.
    static func getGeneration(from pokemonSpecies: PokemonSpecies) async throws -> Generation {
        return try await Generation(pokemonSpecies.generation.url)
    }
    
    /// Gets the PokemonSpecies of a Pokemon.
    /// - Parameter pokemon: The pokemon to get the species from.
    /// - Returns: The PokemonSpecies for the pokemon.
    static func getPokemonSpecies(from pokemon: Pokemon) async throws -> PokemonSpecies {
        return try await PokemonSpecies(pokemon.species.url)
    }
    
    /// Fetches moves from the given URLs.
    ///
    /// The offset skips the first n elements and fetches moves from offset to offset + limit
    ///
    ///     let urls: [URL] = [...]
    ///     let offset = 10
    ///     let moves = getMoves(urls: urls, offset: offset) // starts from urls[offset..< offset + limit]
    ///
    /// - Parameters:
    ///   - urls: The URLs for the moves.
    ///   - limit: The number of moves to fetch.
    ///   - offset: The offset to start from within the URLs.
    /// - Returns: A set of Moves.
    static func getItems<T: Codable & SearchableByURL>(_ type: T.Type, urls: [URL], limit: Int = 0, offset: Int = 0) async throws -> Set<T> {
        var limit = limit
        var offset = offset
        if limit == 0 {
            limit = urls.count
            offset = 0
        }
        return try await withThrowingTaskGroup(of: T.self) { group in
            for (i, url) in urls.enumerated() where i >= offset && i < offset + limit {
                group.addTask {
                    return try await T(url)
                }
            }
            
            var items = Set<T>()
            for try await item in group {
                items.insert(item)
            }
            return items
        }
    }
    
    static func formattedID(_ id: Int) -> String {
        String(format: "#%03d", id)
    }
    
    static func sortedTypes(_ types: Set<`Type`>) -> [`Type`] {
        types.sorted()
    }
}
