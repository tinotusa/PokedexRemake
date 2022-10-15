//
//  ItemCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 15/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class ItemCardViewModel: ObservableObject {
    @Published private(set) var itemCategory: ItemCategory!
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ItemCardViewModel")
}

extension ItemCardViewModel {
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
    
    func localizedItemCategoryName(language: String) -> String {
        itemCategory.names.localizedName(language: language, default: itemCategory.name)
    }
}
