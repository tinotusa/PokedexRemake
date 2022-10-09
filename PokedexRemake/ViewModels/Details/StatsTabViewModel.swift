//
//  StatsTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
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
    
    
    static func formattedID(_ id: Int) -> String {
        String(format: "#%03d", id)
    }
    
    static func sortedTypes(_ types: Set<`Type`>) -> [`Type`] {
        types.sorted()
    }
}

struct StatData: Identifiable {
    let localizedName: String
    let value: Int
    let id = UUID()
}

final class StatsTabViewModel: ObservableObject {
    @Published private(set) var stats: Set<Stat>!
    @Published private(set) var types: Set<`Type`>!
    
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var data = [StatData]()
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "StatsTabViewModel")
    @Published private(set) var damageRelations = [TypeRelationKey: [`Type`]]()
    
    enum TypeRelationKey: String, CaseIterable, Identifiable {
        case noDamageTo = "no damage to"
        case halfDamageTo = "half damage to"
        case doubleDamageTo = "double damage to"
        case noDamageFrom = "no damage from"
        case halfDamageFrom = "half damage from"
        case doubleDamageFrom = "double damage from"
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
        
        var id: Self { self }
    }
}

// MARK: Public functions
extension StatsTabViewModel {
    @MainActor
    func loadData(pokemon: Pokemon, language: String) async {
        logger.debug("Loading stats tab data.")
        do {
            async let stats = getStats(for: pokemon)
            async let types = Globals.getTypes(urls: pokemon.types.map { $0.type.url })
            
            let damageRelations = try await getDamageRelations(for: types)
            
            self.damageRelations = damageRelations
            self.stats = try await stats
            self.types = try await types
            
            let data = getChartData(for: pokemon, language: language)
            self.data = data
            
            viewLoadingState = .loaded
            
            logger.debug("Successfully Loaded stats tab data.")
        } catch {
            logger.error("Failed to load data.")
        }
    }
}

// MARK: Private functions
private extension StatsTabViewModel {
    func getStats(for pokemon: Pokemon) async throws -> Set<Stat> {
        logger.debug("Gettings stats for pokemon with id: \(pokemon.id).")
        
        return try await withThrowingTaskGroup(of: Stat.self) { group in
            for pokemonStat in pokemon.stats {
                group.addTask {
                    let id = pokemonStat.stat.url.lastPathComponent
                    return try await Stat(id)
                }
            }
            
            var stats = Set<Stat>()
            for try await stat in group {
                stats.insert(stat)
            }
            logger.debug("Successfully got \(stats.count) stats for pokemon with id: \(pokemon.id).")
            return stats
        }
    }
    
    func getChartData(for pokemon: Pokemon, language: String) -> [StatData] {
        logger.debug("Getting chart data.")
        
        var data = [StatData]()
        
        for pokemonStat in pokemon.stats {
            guard let statName = pokemonStat.stat.name else {
                logger.error("Failed to get stat name for pokemonStat with url: \(pokemonStat.stat.url).")
                continue
            }
            guard let stat = stats.first(where: { $0.name == statName }) else {
                logger.error("Failed to get stat for pokemonStat with name: \(statName).")
                continue
            }
            data.append(
                .init(
                    localizedName: stat.localizedName(for: language),
                    value: pokemonStat.baseStat
                )
            )
        }
        
        logger.error("Successfully got chart data.")
        return data
    }
    
    func getDamageRelations(for types: Set<`Type`>) async throws -> [TypeRelationKey: [`Type`]] {
        var damageRelations = [TypeRelationKey: [`Type`]]()
        for type in types {
            async let noDamageTo = Globals.getTypes(urls: type.damageRelations.noDamageTo.map { $0.url })
            async let halfDamageTo = Globals.getTypes(urls: type.damageRelations.halfDamageTo.map { $0.url })
            async let doubleDamageTo = Globals.getTypes(urls: type.damageRelations.doubleDamageTo.map { $0.url })
            async let noDamageFrom = Globals.getTypes(urls: type.damageRelations.noDamageFrom.map { $0.url })
            async let halfDamageFrom = Globals.getTypes(urls: type.damageRelations.halfDamageFrom.map { $0.url })
            async let doubleDamageFrom = Globals.getTypes(urls: type.damageRelations.doubleDamageFrom.map { $0.url })
            
            damageRelations[.noDamageTo, default: []].append(contentsOf: try await noDamageTo.sorted())
            damageRelations[.halfDamageTo, default: []].append(contentsOf: try await halfDamageTo.sorted())
            damageRelations[.doubleDamageTo, default: []].append(contentsOf: try await doubleDamageTo.sorted())
            damageRelations[.noDamageFrom, default: []].append(contentsOf: try await noDamageFrom.sorted())
            damageRelations[.halfDamageFrom, default: []].append(contentsOf: try await halfDamageFrom.sorted())
            damageRelations[.doubleDamageFrom, default: []].append(contentsOf: try await doubleDamageFrom.sorted())
        }
        return damageRelations
    }
    
    func getTypes(from resources: [NamedAPIResource]) async -> Set<`Type`> {
        await withTaskGroup(of: `Type`?.self) { group in
            for resource in resources {
                group.addTask { [weak self] in
                    do {
                        guard let name = resource.name else {
                            return nil
                        }
                        return try await Type(name)
                    } catch {
                        self?.logger.error("Failed to get type \(error)")
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
