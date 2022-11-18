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
    /// The ItemCategory for the Item.
    @Published private(set) var itemCategory: ItemCategory?
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ItemCardViewModel")
}

extension ItemCardViewModel {
    /// Loads the relevant data for an Item.
    /// - Parameter item: The Item to load data from.
    @MainActor
    func loadData(item: Item) async {
        logger.debug("Loading data.")
        do {
            itemCategory = try await ItemCategory(item.category.url)
            logger.debug("Successfully loaded data.")
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to load data for item with id: \(item.id). \(error)")
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
