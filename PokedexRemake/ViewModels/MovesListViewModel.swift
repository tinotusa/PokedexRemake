//
//  MovesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for MovesListView.
final class MovesListViewModel: ObservableObject, Pageable {
    /// The PokemonSpecies of the Move
    @Published private(set) var pokemonSpecies: PokemonSpecies?
    /// The Moves to be displayed.
    @Published private(set) var moves = [Move]()
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var pageInfo = PageInfo()
    /// The urls of the moves to fetch.
    private var urls: [URL]
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MovesTabViewModel")
    
    /// Creates the view model with the given urls.
    /// - Parameter urls: The move urls to fetch.
    init(urls: [URL]) {
        self.urls = urls
    }
}

extension MovesListViewModel {
    /// Loads data from the pageInfo offset.
    @MainActor
    func loadPage() async {
        logger.debug("Loading data.")
        do {
            let moves = try await Globals.getItems(Move.self, urls: urls, limit: pageInfo.limit, offset: pageInfo.offset)
            self.moves.append(contentsOf: moves.sorted())
            pageInfo.updateOffset()
            pageInfo.hasNextPage = moves.count == pageInfo.limit
            logger.debug("Successfully loaded moves count: \(moves.count)")
            if !hasLoadedFirstPage {
                viewLoadingState = .loaded
                pageInfo.hasLoadedFirstPage = true
            }
        } catch {
            logger.error("Failed load data.")
            if !hasLoadedFirstPage {
                viewLoadingState = .error(error: error)
            }
        }
    }
}
