//
//  ItemCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 15/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for ItemCard
final class ItemCardViewModel: ObservableObject {
    /// The item to load data from.
    private var item: Item
    /// The ItemCategory for the Item.
    @Published private(set) var itemCategory: ItemCategory?
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The localised name of the item.
    @Published private(set) var itemName = "Error"
    /// The localised EffectEntry of the item.
    @Published private(set) var effectEntry = "Error"
    /// The localised ItemCategory of the item.
    @Published private(set) var itemCategoryName = "Error"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ItemCardViewModel")
    
    /// Creates the view model.
    /// - Parameter item: The Item to display and load data from
    init(item: Item) {
        self.item = item
    }
}

extension ItemCardViewModel {
    /// Loads the relevant data for an Item.
    /// - Parameter item: The Item to load data from.
    @MainActor
    func loadData(languageCode: String) async {
        logger.debug("Loading data for item with id: \(self.item.id)")
        do {
            let itemCategory = try await ItemCategory(item.category.url)
            self.itemCategory = itemCategory
            itemName = item.localizedName(languageCode: languageCode)
            effectEntry = item.effectEntries.localizedEntry(language: languageCode, shortVersion: true)
            itemCategoryName = itemCategory.localizedName(languageCode: languageCode)
            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for item with id: \(self.item.id).")
        } catch {
            logger.error("Failed to load data for item with id: \(self.item.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    /// Returns the localised name for the Item's ItemCategory
    /// - Parameter language: The language code to localise with
    /// - Returns: A localised ItemCategory name or "Error"
    func localizedItemCategoryName(language: String) -> String {
        if let itemCategory {
            return itemCategory.localizedName(languageCode: language)
        }
        logger.error("ItemCategory is nil.")
        return "Error"
    }
}
