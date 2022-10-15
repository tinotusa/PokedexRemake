//
//  ItemsCategoryViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 15/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class ItemsCategoryViewModel: ObservableObject, Identifiable {
    let id = UUID().uuidString
    @Published private var items = Set<Item>()
    @Published private var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var hasNextPage = true
    @Published private var nextPageURL: URL? {
        didSet {
            if nextPageURL == nil { hasNextPage = false }
        }
    }
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ItemsCategoryViewModel")
}

// MARK: - Public functions
extension ItemsCategoryViewModel {
    func loadData() async {
        logger.error("Loading data.")
        do {
            let itemsResource = try await Resource<Item>(limit: 20)
            self.nextPageURL = itemsResource.next
            self.items = itemsResource.items
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    func getNextPageItems() async {
        guard let nextPageURL else {
            logger.error("Failed to get next page items. nextPageURL is nil.")
            return
        }
        do {
            let itemsResource = try await Resource<Item>(nextPageURL)
            self.nextPageURL = itemsResource.next
            self.items.formUnion(itemsResource.items)
        } catch {
            logger.error("Failed to get next items page. \(error)")
        }
        return
    }
}

// MARK: - Private functions
private extension ItemsCategoryViewModel {
}
