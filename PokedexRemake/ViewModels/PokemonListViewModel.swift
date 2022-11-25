//
//  PokemonListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import Foundation
import SwiftPokeAPI
import os
import SwiftUI

/// View model for PokemonList.
final class PokemonListViewModel: ObservableObject, Pageable {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The pokemon urls to fetch Pokemon from.
    @Published private var urls: [URL]
    /// The Pokemon for the list.
    @Published private(set) var pokemon = [Pokemon]()
    /// The current page information.
    @Published private(set) var pageInfo = PageInfo()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonListViewModel")
    
    /// Creates the view model.
    /// - Parameter urls: The urls to load pokemon from.
    init(urls: [URL]) {
        self.urls = urls
    }
}

extension PokemonListViewModel {    
    @MainActor
    /// Uses the pageInfo to fetch the the current page.
    func loadPage() async {
        logger.debug("Loading page.")
        do {
            logger.debug("Loading page.")
            let pokemon = try await Globals.getItems(Pokemon.self, urls: urls, limit: pageInfo.limit, offset: pageInfo.offset)
            self.pokemon.append(contentsOf: pokemon.sorted())
            pageInfo.updateOffset()
            pageInfo.hasNextPage = pokemon.count == pageInfo.limit
            viewLoadingState = .loaded
            logger.debug("Successfully loaded the page.")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load the page. \(error)")
        }
    }
}
