//
//  StatsTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

struct StatData: Identifiable {
    let localizedName: String
    let value: Int
    let id = UUID()
}

final class StatsTabViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var data = [StatData]()
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "StatsTabViewModel")
}

// MARK: Public functions
extension StatsTabViewModel {
    @MainActor
    func loadData(pokemonData: PokemonData, pokemonDataStore: PokemonDataStore, language: String) async {
        logger.debug("Loading stats tab data.")
        let stats = await getStats(for: pokemonData.pokemon, pokemonDataStore: pokemonDataStore)
        pokemonDataStore.addStats(stats)
        let data = getChartData(for: pokemonData.pokemon, pokemonDataStore: pokemonDataStore, language: language)
        
        
        self.data = data
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
}
