//
//  AbilitiesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for AbilitiesList.
final class AbilitiesListViewModel: ObservableObject, Pageable {
    /// The abilities of the pokemon.
    @Published private(set) var abilities = [Ability]()
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var pageInfo = PageInfo()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilitiesViewModel")
    private let pokemon: Pokemon
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
    }
}

extension AbilitiesListViewModel {
    /// Loads the relevant data for the given Pokemon.
    @MainActor
    func loadPage() async {
        logger.debug("Loading page.")
        do {
            let abilities = try await Globals.getItems(
                Ability.self,
                urls: pokemon.abilities.map { $0.ability.url },
                limit: pageInfo.limit,
                offset: pageInfo.offset
            )
            self.abilities.append(contentsOf: abilities.sorted())
            pageInfo.updateOffset()
            pageInfo.hasNextPage = abilities.count == pageInfo.limit
            if !hasLoadedFirstPage {
                viewLoadingState = .loaded
                pageInfo.hasLoadedFirstPage = true
            }
            logger.debug("Successfully loaded data.")
        } catch {
            if !hasLoadedFirstPage {
                viewLoadingState = .error(error: error)
            }
            logger.error("Failed to load data. \(error)")
        }
    }
}
