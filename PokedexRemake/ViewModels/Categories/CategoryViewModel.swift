//
//  CategoryViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for CategoryView.
final class CategoryViewModel<T: Codable & Hashable & Identifiable & SearchableByURL & Comparable>: ObservableObject, Pageable {
    @Published var values = [T]()
    @Published var pageInfo = PageInfo()
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private var logger = Logger(subsystem: "com.tinotusa.Pokedex", category: "CategoryViewViewModel")
    
    enum CategoryError: Error {
        case noNextPage
    }
    
    /// Loads page data based on the page state and page info.
    @MainActor
    func loadPage() async {
        logger.debug("Loading first page.")
        do {
            let items = try await Resource<T>(limit: pageInfo.limit, offset: pageInfo.offset)
            self.values = items.items.sorted()
            self.pageInfo.updateOffset()
            self.pageInfo.hasNextPage = items.items.count == pageInfo.limit
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to load page. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
