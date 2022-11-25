//
//  AbilityListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 3/11/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for AbilityListView.
final class AbilityListViewModel: ObservableObject, Pageable {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The abilities to be displayed.
    @Published private(set) var abilities = [Ability]()
    /// The current pages information.
    @Published private(set) var pageInfo = PageInfo()
    /// The ability urls to fetch data from.
    private var urls = [URL]()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityListViewModel")
    
    /// Creates the view model
    /// - Parameter urls: The ability urls to fetch data from.
    init(urls: [URL]) {
        self.urls = urls
    }
}

extension AbilityListViewModel {
    @MainActor
    /// Loads the page based on the current pageInfo.
    func loadPage() async {
        logger.debug("Loading page.")
        if !pageInfo.hasNextPage {
            logger.debug("Failed to load page. pageInfo has no next page.")
            return
        }
        do {
            let abilities = try await Globals.getItems(Ability.self, urls: urls, limit: pageInfo.limit, offset: pageInfo.offset)
            self.abilities.append(contentsOf: abilities.sorted())
            self.pageInfo.updateOffset()
            self.pageInfo.hasNextPage = abilities.count == pageInfo.limit
            if !hasLoadedFirstPage {
                viewLoadingState = .loaded
                pageInfo.hasLoadedFirstPage = true
            }
            logger.debug("Successfully loaded the page. loaded \(abilities.count) items.")
        } catch {
            if !hasLoadedFirstPage {
                viewLoadingState = .error(error: error)
            }
            logger.error("Failed to load page. \(error)")
        }
    }
}
