//
//  ItemResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class ItemResultsViewModel: ObservableObject {
    @Published private(set) var items = [Item]()
    @Published private(set) var hasNextPage = true
    @Published private var nextPageURL: URL? {
        didSet {
            if nextPageURL == nil { hasNextPage = false }
        }
    }
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "ItemResultsViewModel")
}

extension ItemResultsViewModel {
    func loadData() {
        viewLoadingState = .loaded
    }
    
    /// Searches for an Item with the given name.
    /// - parameter name: The name to search for an item with.
    func search(_ name: String) async {
        do {
            let item = try await Item(name)
            let moved = items.moveToTop(item)
            if !moved {
                self.items.insert(item, at: 0)
            }
        } catch {
            logger.error("Failed to find item with name: \(name). \(error)")
        }
    }
}
