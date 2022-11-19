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

/// Stat data used for the chart.
struct StatData: Identifiable {
    /// The localised name of the stat.
    let localizedName: String
    /// The value of the stat.
    let value: Int
    /// A unique identifier for this data point.
    let id = UUID()
}

/// View model for StatsTab.
final class StatsTabViewModel: ObservableObject {
    /// The stats of the Pokemon.
    @Published private(set) var stats = Set<Stat>()
    /// The types of the Pokemon.
    @Published private(set) var types = Set<`Type`>()
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// An array of StatData to display in a chart.
    @Published private(set) var data = [StatData]()
    /// The damage relations and types.
    @Published private(set) var damageRelations = [TypeRelationKey: [`Type`]]()
    
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "StatsTabViewModel")
    
    /// Keys for the damage relations.
    enum TypeRelationKey: String, CaseIterable, Identifiable {
        case noDamageTo = "no damage to"
        case halfDamageTo = "half damage to"
        case doubleDamageTo = "double damage to"
        case noDamageFrom = "no damage from"
        case halfDamageFrom = "half damage from"
        case doubleDamageFrom = "double damage from"
        
        /// The title for the key.
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
        
        /// A unique identifier for the key.
        var id: Self { self }
    }
}

// MARK: Public functions
extension StatsTabViewModel {
    /// Loads the relevant data from the given Pokemon.
    /// - Parameters:
    ///   - pokemon: The Pokemon to load data from.
    ///   - language: The language code used for localisation.
    @MainActor
    func loadData(pokemon: Pokemon, language: String) async {
        logger.debug("Loading stats tab data.")
        do {
            async let stats = Globals.getItems(Stat.self, urls: pokemon.stats.map { $0.stat.url })
            async let types = Globals.getItems(`Type`.self, urls: pokemon.types.map { $0.type.url })
            
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
    /// Returns an array of StatData.
    /// - Parameters:
    ///   - pokemon: The Pokemon to get stat data form.
    ///   - language: The language code used for localisation.
    /// - Returns: An array of StatData.
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
                    localizedName: stat.localizedName(languageCode: language),
                    value: pokemonStat.baseStat
                )
            )
        }
        
        logger.error("Successfully got chart data.")
        return data
    }
    
    /// Returns all of the damage relations based on this Pokemon's types.
    /// - Parameter types: The types to get the damage relations for.
    /// - Returns: A dictionary of TypeRelationKey and array of Types.
    func getDamageRelations(for types: Set<`Type`>) async throws -> [TypeRelationKey: [`Type`]] {
        var damageRelations = [TypeRelationKey: Set<`Type`>]()
        for type in types {
            async let noDamageTo = Globals.getItems(`Type`.self, urls: type.damageRelations.noDamageTo.map { $0.url })
            async let halfDamageTo = Globals.getItems(`Type`.self, urls: type.damageRelations.halfDamageTo.map { $0.url })
            async let doubleDamageTo = Globals.getItems(`Type`.self, urls: type.damageRelations.doubleDamageTo.map { $0.url })
            async let noDamageFrom = Globals.getItems(`Type`.self, urls: type.damageRelations.noDamageFrom.map { $0.url })
            async let halfDamageFrom = Globals.getItems(`Type`.self, urls: type.damageRelations.halfDamageFrom.map { $0.url })
            async let doubleDamageFrom = Globals.getItems(`Type`.self, urls: type.damageRelations.doubleDamageFrom.map { $0.url })
            
            damageRelations[.noDamageTo, default: []].formUnion(try await noDamageTo.sorted())
            damageRelations[.halfDamageTo, default: []].formUnion(try await halfDamageTo.sorted())
            damageRelations[.doubleDamageTo, default: []].formUnion(try await doubleDamageTo.sorted())
            damageRelations[.noDamageFrom, default: []].formUnion(try await noDamageFrom.sorted())
            damageRelations[.halfDamageFrom, default: []].formUnion(try await halfDamageFrom.sorted())
            damageRelations[.doubleDamageFrom, default: []].formUnion(try await doubleDamageFrom.sorted())
        }
        return damageRelations.mapValues { $0.sorted() }
    }
}
