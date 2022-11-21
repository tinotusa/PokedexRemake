//
//  CategoryViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class CategoryViewModel<T: Codable & Hashable & Identifiable & SearchableByURL & Comparable>: ObservableObject, Pageable {
    @Published var values = [T]()
    @Published var pageInfo = PageInfo()
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var pageState = PaginationState.loadingFirstPage
    
    private var logger = Logger(subsystem: "com.tinotusa.Pokedex", category: "CategoryViewViewModel")
    
    enum CategoryError: Error {
        case noNextPage
    }
    
    @MainActor
    func loadPage() async {
        switch pageState {
        case .loadingFirstPage:
            logger.debug("Loading first page.")
            do {
                let (items, pageInfo) = try await loadPage(pageInfo: self.pageInfo)
                self.values = items.sorted()
                self.pageInfo = pageInfo
                viewLoadingState = .loaded
                pageState = .loaded
            } catch {
                logger.error("Failed to load page. \(error)")
                viewLoadingState = .error(error: error)
            }
        // TODO: is this an error.
        case .loaded, .loadingNextPage:
            do {
                logger.debug("Loading next page.")
                pageState = .loadingNextPage
                let (items, pageInfo) = try await loadPage(pageInfo: pageInfo)
                self.values.append(contentsOf: items.sorted())
                self.pageInfo = pageInfo
                pageState = .loaded
            } catch {
                logger.error("Failed to load next page. \(error)")
                pageState = .error(error: error)
            }
        case .error(let error):
            logger.error("Failed \(error)")
        }
    }
    
    func loadPage(pageInfo: PageInfo) async throws -> (items: [T], pageInfo: PageInfo) {
        let items = try await Resource<T>(limit: pageInfo.limit, offset: pageInfo.offset)
        return (
            items: Array(items.items),
            pageInfo: .init(
                offset: pageInfo.offset + pageInfo.limit,
                hasNextPage: items.next != nil
            )
        )
    }
}
