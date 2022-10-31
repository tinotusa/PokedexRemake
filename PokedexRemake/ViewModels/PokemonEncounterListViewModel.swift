//
//  PokemonEncounterListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 31/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class PokemonEncounterListViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var pokemon = [Pokemon]()
    @Published private(set) var pokemonSpecies = [PokemonSpecies]()
    @Published private var versions = Set<Version>()
    @Published private(set) var encounterMethods = Set<EncounterMethod>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonEncounterListViewModel")
}

extension PokemonEncounterListViewModel {
    @MainActor
    func loadData(pokemonEncounters: [PokemonEncounter]) async {
        do {
            self.pokemon = try await getPokemon(pokemonEncounters: pokemonEncounters)
            self.pokemonSpecies = try await getPokemonSpecies(pokemonArray: pokemon)
            self.versions.formUnion(try await getVersions(pokemonEncounters: pokemonEncounters))
            self.encounterMethods.formUnion(try await getEncounterMethods(pokemonEncounters: pokemonEncounters))
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    var sortedVersions: [Version] {
        self.versions.sorted()
    }
}

private extension PokemonEncounterListViewModel {
    func getPokemon(pokemonEncounters: [PokemonEncounter]) async throws -> [Pokemon] {
        try await withThrowingTaskGroup(of: Pokemon.self) { group in
            for encounter in pokemonEncounters {
                group.addTask {
                    return try await Pokemon(encounter.pokemon.url)
                }
            }
            
            var pokemonArray = [Pokemon]()
            for try await pokemon in group {
                pokemonArray.append(pokemon)
            }
         
            return pokemonArray.sorted()
        }
    }
    
    func getPokemonSpecies(pokemonArray: [Pokemon]) async throws -> [PokemonSpecies] {
        try await withThrowingTaskGroup(of: PokemonSpecies.self) { group in
            for pokemon in pokemonArray {
                group.addTask {
                    return try await PokemonSpecies(pokemon.species.url)
                }
            }
            
            var pokemonArray = [PokemonSpecies]()
            for try await pokemon in group {
                pokemonArray.append(pokemon)
            }
            return pokemonArray.sorted()
        }
    }
    
    func getVersions(pokemonEncounters: [PokemonEncounter]) async throws -> [Version] {
        try await withThrowingTaskGroup(of: Version.self) { group in
            for encounter in pokemonEncounters {
                for versionDetail in encounter.versionDetails {
                    group.addTask {
                        return try await Version(versionDetail.version.url)
                    }
                }
            }
            
            var versions = [Version]()
            for try await version in group {
                versions.append(version)
            }
            return versions
        }
    }
    
    func getEncounterMethods(pokemonEncounters: [PokemonEncounter]) async throws -> [EncounterMethod] {
        try await withThrowingTaskGroup(of: EncounterMethod.self) { group in
            for encounter in pokemonEncounters {
                for test in encounter.versionDetails {
                    for anotherOne in test.encounterDetails {
                        group.addTask {
                            return try await EncounterMethod(anotherOne.method.url)
                        }
                    }
                }
            }
            
            var methods = [EncounterMethod]()
            for try await encounterMethod in group {
                methods.append(encounterMethod)
            }
            return methods
        }
    }
}
