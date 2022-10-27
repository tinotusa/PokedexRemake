//
//  ItemDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 24/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

final class ItemDetailViewModel: ObservableObject {
    @Published private(set) var flingEffect: ItemFlingEffect?
    @Published private(set) var category: ItemCategory?
    @Published private(set) var babyTrigger: EvolutionChain?
    @Published private(set) var attributes = [ItemAttribute]()
    @Published private(set) var localizedFlavorTextEntries = [VersionGroupFlavorText]()
    @Published private(set) var itemDetails: [ItemDetailKey: String] = [:]
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published var showingFlavorTextList = false
    @Published var showingMachinesList = false
    @Published var showingPokemonList = false
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ItemDetailViewModel")
    private var languageCode = SettingsKey.defaultLanguage
    
    enum ItemDetailKey: String, CaseIterable, Identifiable {
        case cost
        case flingPower = "fling power"
        case flingEffect = "fling effect"
        case attributes
        case category
        case flavorTextEntries = "Flavor texts"
        case heldByPokemon = "Held by pokemon"
        case babyTriggerFor = "Baby trigger for"
        case machines
        
        var id: Self { self }
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
}

extension ItemDetailViewModel {
    @MainActor
    func loadData(item: Item, languageCode: String) async {
        self.languageCode = languageCode
        do {
            if let flingEffect = item.flingEffect {
                self.flingEffect = try await ItemFlingEffect(flingEffect.url)
            }
            self.category = try await ItemCategory(item.category.url)
            if let babyTriggerFor = item.babyTriggerFor {
                self.babyTrigger = try await EvolutionChain(babyTriggerFor.url)
            }
            self.attributes = try await getItemAttributes(item: item).sorted()
            
            self.localizedFlavorTextEntries = getLocalizedFlavorTextEntries(item: item)
            self.itemDetails = getItemDetails(item: item)
            
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    func getItemAttributes(item: Item) async throws -> [ItemAttribute] {
        try await withThrowingTaskGroup(of: ItemAttribute.self) { group in
            for attribute in item.attributes {
                group.addTask {
                    try await ItemAttribute(attribute.url)
                }
            }
            
            var attributes = Set<ItemAttribute>()
            for try await attribute in group {
                attributes.insert(attribute)
            }
            return Array(attributes)
        }
    }
    
    func getLocalizedFlavorTextEntries(item: Item) -> [VersionGroupFlavorText] {
        var entries: [VersionGroupFlavorText]?
        entries = item.flavorTextEntries.localizedItems(for: "en")
        // TODO: Do i need to filter these flavor texts? (an extension on the type itself?)
        if let entries {
            return entries
        }
        logger.error("Failed to get localized flavor text entries")
        return []
    }
    
    func getItemDetails(item: Item) -> [ItemDetailKey: String] {
        var details = [ItemDetailKey: String]()
        details[.cost] = "\(item.cost)"
        if let flingPower = item.flingPower {
            details[.flingPower] = "\(flingPower)"
        }
        if let flingEffect {
            details[.flingEffect] = flingEffect.name
        }
        details[.attributes] = "\(item.attributes.count)"
        if let category {
            details[.category] = category.names.localizedName(language: self.languageCode, default: category.name)
        }
        details[.flavorTextEntries] = "\(localizedFlavorTextEntries.count)"
        details[.heldByPokemon] = "\(item.heldByPokemon.count)"
        if let babyTrigger {
            details[.babyTriggerFor] = babyTrigger.chain.species.name!
        }
        details[.machines] = "\(item.machines.count)"
        return details
    }
}
