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
                    return try await `Type`(url)
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
        return try await Generation(pokemonSpecies.generation.url)
    }
    
    static func getPokemonSpecies(from pokemon: Pokemon) async throws -> PokemonSpecies {
        return try await PokemonSpecies(pokemon.species.url)
    }
    
    static func getMoves(urls: [URL]) async throws -> Set<Move> {
        try await withThrowingTaskGroup(of: Move.self) { group in
            for url in urls {
                group.addTask {
                    return try await Move(url)
                }
            }
            
            var moves = Set<Move>()
            for try await move in group {
                moves.insert(move)
            }
            return moves
        }
    }
    
    static func getAbilities(urls: [URL]) async throws -> Set<Ability> {
        try await withThrowingTaskGroup(of: Ability.self) { group in
            for url in urls {
                group.addTask {
                    return try await Ability(url)
                }
            }
            
            var abilities = Set<Ability>()
            for try await ability in group {
                abilities.insert(ability)
            }
            return abilities
        }
    }
    
    static func getVersionGroups(from urls: [URL]) async throws -> Set<VersionGroup> {
        try await withThrowingTaskGroup(of: VersionGroup.self) { group in
            for url in urls {
                group.addTask {
                    return try await VersionGroup(url)
                }
            }
            
            var versionGroups = Set<VersionGroup>()
            for try await versionGroup in group {
                versionGroups.insert(versionGroup)
            }
            return versionGroups
        }
    }
    
    static func getVersions(from versionGroups: Set<VersionGroup>) async throws -> Set<Version> {
        try await withThrowingTaskGroup(of: Version.self) { group in
            for versionGroup in versionGroups {
                for version in versionGroup.versions {
                    group.addTask {
                        return try await Version(version.url)
                    }
                }
            }
            
            var versions = Set<Version>()
            for try await version in group {
                versions.insert(version)
            }
            return versions
        }
    }
    
    static func formattedID(_ id: Int) -> String {
        String(format: "#%03d", id)
    }
    
    static func sortedTypes(_ types: Set<`Type`>) -> [`Type`] {
        types.sorted()
    }
}
