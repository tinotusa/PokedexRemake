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

struct StatData: Identifiable {
    let localizedName: String
    let value: Int
    let id = UUID()
}

final class StatsTabViewModel: ObservableObject {
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
    func loadData(pokemonData: PokemonData, pokemonDataStore: PokemonDataStore, language: String) async {
        logger.debug("Loading stats tab data.")
        let stats = await getStats(for: pokemonData.pokemon, pokemonDataStore: pokemonDataStore)
        pokemonDataStore.addStats(stats)
        let data = getChartData(for: pokemonData.pokemon, pokemonDataStore: pokemonDataStore, language: language)
        let damageRelations = await getDamageRelations(for: pokemonData.types, pokemonDataStore: pokemonDataStore)
        
        self.data = data
        self.damageRelations = damageRelations
        viewLoadingState = .loaded
        
        logger.debug("Successfully Loaded stats tab data.")
    }
}

// MARK: Private functions
private extension StatsTabViewModel {
    func getStats(for pokemon: Pokemon, pokemonDataStore: PokemonDataStore) async -> Set<Stat> {
        logger.debug("Gettings stats for pokemon with id: \(pokemon.id).")
        
        return await withTaskGroup(of: Stat?.self) { group in
            for pokemonStat in pokemon.stats {
                
                group.addTask { [weak self] in
                    do {
                        guard let name = pokemonStat.stat.name else {
                            return nil
                        }
                        if pokemonDataStore.stats.contains(where: { $0.name == name }) {
                            self?.logger.debug("Stat named \(name) already in pokemon data store.")
                            return nil
                        }
                        return try await Stat(name)
                    } catch {
                        self?.logger.error("Failed to get stat for pokemon with id: \(pokemon.id). \(error)")
                    }
                    return nil
                }
            }
            
            var stats = Set<Stat>()
            for await stat in group {
                guard let stat else { continue }
                stats.insert(stat)
            }
            logger.debug("Successfully got \(stats.count) stats for pokemon with id: \(pokemon.id).")
            return stats
        }
    }
    
    func getChartData(for pokemon: Pokemon, pokemonDataStore: PokemonDataStore, language: String) -> [StatData] {
        logger.debug("Getting chart data.")
        
        var data = [StatData]()
        let stats = pokemonDataStore.stats(for: pokemon)
        
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
    
    func getDamageRelations(for types: Set<`Type`>, pokemonDataStore: PokemonDataStore) async -> [TypeRelationKey: [`Type`]] {
        var damageRelations = [TypeRelationKey: [`Type`]]()
        for type in types {
            async let noDamageTo = getTypes(from: type.damageRelations.noDamageTo, pokemonDataStore: pokemonDataStore)
            async let halfDamageTo = getTypes(from: type.damageRelations.halfDamageTo, pokemonDataStore: pokemonDataStore)
            async let doubleDamageTo = getTypes(from: type.damageRelations.doubleDamageTo, pokemonDataStore: pokemonDataStore)
            async let noDamageFrom = getTypes(from: type.damageRelations.noDamageFrom, pokemonDataStore: pokemonDataStore)
            async let halfDamageFrom = getTypes(from: type.damageRelations.halfDamageFrom, pokemonDataStore: pokemonDataStore)
            async let doubleDamageFrom = getTypes(from: type.damageRelations.doubleDamageFrom, pokemonDataStore: pokemonDataStore)
            
            await pokemonDataStore.addTypes(noDamageTo)
            await pokemonDataStore.addTypes(halfDamageTo)
            await pokemonDataStore.addTypes(doubleDamageTo)
            await pokemonDataStore.addTypes(noDamageFrom)
            await pokemonDataStore.addTypes(halfDamageFrom)
            await pokemonDataStore.addTypes(doubleDamageFrom)
            
            damageRelations[.noDamageTo, default: []].append(contentsOf: await noDamageTo.sorted())
            damageRelations[.halfDamageTo, default: []].append(contentsOf: await halfDamageTo.sorted())
            damageRelations[.doubleDamageTo, default: []].append(contentsOf: await doubleDamageTo.sorted())
            damageRelations[.noDamageFrom, default: []].append(contentsOf: await noDamageFrom.sorted())
            damageRelations[.halfDamageFrom, default: []].append(contentsOf: await halfDamageFrom.sorted())
            damageRelations[.doubleDamageFrom, default: []].append(contentsOf: await doubleDamageFrom.sorted())
        }
        return damageRelations
    }
    
    func getTypes(from resources: [NamedAPIResource], pokemonDataStore: PokemonDataStore) async -> Set<`Type`> {
        await withTaskGroup(of: `Type`?.self) { group in
            for resource in resources {
                group.addTask { [weak self] in
                    do {
                        guard let name = resource.name else {
                            return nil
                        }
                        if let type = pokemonDataStore.types.first(where: { $0.name == name }) {
                            self?.logger.debug("Type named: \(name) is already in data store.")
                            return type
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
