//
//  AboutTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import Foundation
import SwiftUI
import SwiftPokeAPI
import os

final class AboutTabViewModel: ObservableObject {
    @Published private(set) var pokemonSpecies: PokemonSpecies!
    @Published private(set) var types: Set<`Type`>!
    @Published private(set) var items: Set<Item>!
    @Published private(set) var versions: Set<Version>!
    
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AboutTabViewModel")
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published var showAllEntries = false
    @Published private(set) var language = "en"
    @Published private(set) var aboutInfo = [AboutInfo: String]()
    let minEntryCount = 3
    
    enum AboutInfo: String, CaseIterable, Identifiable {
        case name
        case types
        case height
        case weight
        case isDefault = "is default"
        case heldItems = "held items"
        case baseExperience = "base experience"
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
        
        var id: Self { self }
    }
}

extension AboutTabViewModel {
    @MainActor
    func loadData(pokemon: Pokemon) async {
        do {
            let pokemonSpecies = try await getPokemonSpecies(from: pokemon)
            
            async let versions = loadVersions(pokemonSpecies: pokemonSpecies)
            async let items = getHeldItems(pokemon: pokemon)
            async let types = getTypes(from: pokemon)
            
            self.pokemonSpecies = pokemonSpecies
            self.versions = await versions
            self.items = await items
            self.types = try await types
            
            self.aboutInfo = getAboutInfo(pokemon: pokemon, pokemonSpecies: pokemonSpecies)
            
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to load data.")
            viewLoadingState = .error(error: error)
        }
    }
    
    func showEntries(from flavorTexts: [FlavorText]) -> [FlavorText] {
        if showAllEntries {
            return flavorTexts
        } else {
            if flavorTexts.count <= minEntryCount {
                return flavorTexts
            }
            return Array(flavorTexts[ ..<minEntryCount])
        }
    }
    
    func sortedTypes() -> [`Type`] {
        types.sorted()
    }
}
// MARK: Private functions
private extension AboutTabViewModel {
    func getPokemonSpecies(from pokemon: Pokemon) async throws -> PokemonSpecies {
        do {
            let id = pokemon.species.url.lastPathComponent
            return try await PokemonSpecies(id)
        } catch {
            logger.error("Failed to get pokemon species from pokemon with id \(pokemon.id). \(error)")
            throw error
        }
    }
    func loadVersions(pokemonSpecies: PokemonSpecies) async -> Set<Version> {
        let versions = await withTaskGroup(of: Version?.self) { group in
            for entry in pokemonSpecies.flavorTextEntries {
                group.addTask { [weak self] in
                    do {
                        guard let name = entry.version?.name else {
                            return nil
                        }
                        return try await Version(name)
                    } catch {
                        self?.logger.error("Failed to get version. \(error)")
                    }
                    return nil
                }
            }
            
            var versions = Set<Version>()
            for await version in group {
                guard let version else { continue }
                versions.insert(version)
            }
            return versions
        }
        
        return versions
    }
    
    func getHeldItems(pokemon: Pokemon) async -> Set<Item> {
        let items = await withTaskGroup(of: Item?.self) { group in
            for heldItem in pokemon.heldItems {
                group.addTask { [weak self] in
                    do {
                        guard let name = heldItem.item.name else {
                            return nil
                        }
                        return try await Item(name)
                    } catch {
                        self?.logger.error("Failed to get item. \(error)")
                    }
                    return nil
                }
            }
            
            var items = Set<Item>()
            for await item in group {
                guard let item else { continue }
                items.insert(item)
            }
            return items
        }
        
        return items
    }
    
    func getTypes(from pokemon: Pokemon) async throws  -> Set<`Type`> {
        try await withThrowingTaskGroup(of: `Type`.self) { group in
            for pokemonType in pokemon.types {
                group.addTask {
                    let id = pokemonType.type.url.lastPathComponent
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
    
    func getAboutInfo(pokemon: Pokemon, pokemonSpecies: PokemonSpecies) -> [AboutInfo: String] {
        var aboutInfo: [AboutInfo: String] = [:]
        
        aboutInfo[.name] = pokemonSpecies.localizedName(for: language)
        aboutInfo[.types] = "\(pokemon.types.count) types"
        aboutInfo[.height] = Measurement(value: Double(pokemon.height), unit: UnitLength.decimeters).formatted()
        aboutInfo[.weight] = Measurement(value: Double(pokemon.weightInKG), unit: UnitMass.kilograms).formatted()
        aboutInfo[.isDefault] = pokemon.isDefault ? "Yes" : "No"
        aboutInfo[.heldItems] = "\(pokemon.heldItems.count) items"
        aboutInfo[.baseExperience] = "\(pokemon.baseExperience ?? 0)"
        
        return aboutInfo
    }
}
