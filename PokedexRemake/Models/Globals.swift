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
    
    static func getAbilities(urls: [URL]) async throws -> Set<Ability> {
        try await withThrowingTaskGroup(of: Ability.self) { group in
            for url in urls {
                group.addTask {
                    let id = url.lastPathComponent
                    return try await Ability(id)
                }
            }
            
            var abilities = Set<Ability>()
            for try await ability in group {
                abilities.insert(ability)
            }
            return abilities
        }
    }
    
    static func getVersionGroups(from abilityFlavorTexts: [AbilityFlavorText]) async throws -> Set<VersionGroup> {
        try await withThrowingTaskGroup(of: VersionGroup.self) { group in
            for abilityFlavorText in abilityFlavorTexts {
                group.addTask {
                    let id = abilityFlavorText.versionGroup.url.lastPathComponent
                    return try await VersionGroup(id)
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
                        let id = version.url.lastPathComponent
                        return try await Version(id)
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
