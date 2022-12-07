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

/// View model for ItemDetail.
final class ItemDetailViewModel: ObservableObject {
    /// The flingEffect of the Item to be displayed.
    @Published private(set) var flingEffect: ItemFlingEffect?
    /// The category of the Item to be displayed.
    @Published private(set) var category: ItemCategory?
    /// The babyTrigger of the Item to be displayed.
    @Published private(set) var babyTrigger: EvolutionChain?
    /// The attributes of the Item to be displayed.
    @Published private(set) var attributes = [ItemAttribute]()
    /// The localizedFlavorTextEntries of the Item to be displayed.
    @Published private(set) var localizedFlavorTextEntries = [VersionGroupFlavorText]()
    /// The itemDetails of the Item to be displayed.
    @Published private(set) var itemDetails: [ItemDetailKey: String] = [:]
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The custom flavor texts of the item.
    @Published private(set) var customFlavorTexts = [CustomFlavorText]()
    /// The short effect entry of the item.
    @Published private(set) var shortEffectEntry = "Error"
    /// The long effect entry of the item.
    @Published private(set) var longEffectEntry = "Error"
    /// A Boolean value indicating whether or not the flavorText list is showing.
    @Published var showingFlavorTextList = false
    /// A Boolean value indicating whether or not the machines list is showing.
    @Published var showingMachinesList = false
    /// A Boolean value indicating whether or not the pokemon list is showing.
    @Published var showingPokemonList = false
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ItemDetailViewModel")
    
    /// The item detail keys.
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
        
        /// A unique identifier for the key.
        var id: Self { self }
        
        /// The localised title for the key.
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
}

extension ItemDetailViewModel {
    /// Loads the relevant data for the view.
    /// - Parameters:
    ///   - item: The Item to load data from.
    ///   - languageCode: The language code used for localisations.
    @MainActor
    func loadData(item: Item, languageCode: String) async {
        logger.debug("Loading data.")
        do {
            if let flingEffect = item.flingEffect {
                self.flingEffect = try await ItemFlingEffect(flingEffect.url)
            }
            self.category = try await ItemCategory(item.category.url)
            if let babyTriggerFor = item.babyTriggerFor {
                self.babyTrigger = try await EvolutionChain(babyTriggerFor.url)
            }
            self.attributes = try await Globals.getItems(ItemAttribute.self, urls: item.attributes.map { $0.url }).sorted()
            
            self.shortEffectEntry = item.effectEntries.localizedEntry(language: languageCode, shortVersion: true)
            self.longEffectEntry = item.effectEntries.localizedEntry(language: languageCode)
            
            self.localizedFlavorTextEntries = item.flavorTextEntries.localizedItems(for: languageCode)
            self.customFlavorTexts = localizedFlavorTextEntries.map { entry in
                CustomFlavorText(
                    flavorText: entry.text.replacingOccurrences(of: "[\\n\\s]+", with: " ", options: .regularExpression),
                    language: entry.language,
                    versionGroup: entry.versionGroup
                )
            }
            self.itemDetails = getItemDetails(item: item, languageCode: languageCode)
            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for item with id: \(item.id)")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data for item with id: \(item.id). \(error)")
        }
    }
}

private extension ItemDetailViewModel {
    /// Returns a dictionary of the item's details and values.
    /// - Parameters:
    ///   - item: The item to get details from.
    ///   - languageCode: The language code used for localisation.
    /// - Returns: A dictionary of item detail keys and values.
    func getItemDetails(item: Item, languageCode: String) -> [ItemDetailKey: String] {
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
            details[.category] = category.localizedName(languageCode: languageCode)
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
