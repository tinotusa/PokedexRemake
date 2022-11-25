//
//  AbilityListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 3/11/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class AbilityListViewModel: ObservableObject, Pageable {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    @Published private(set) var values = [Ability]()
    @Published private(set) var pageInfo = PageInfo(limit: 20)
    
    private var urls = [URL]()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityListViewModel")
}

extension AbilityListViewModel {
    @MainActor
    func setUp(urls: [URL]) {
        self.urls = urls
    }
    
    @MainActor
    func loadPage() async {
        if !pageInfo.hasNextPage {
            return
        }
        do {
            let abilities = try await Globals.getItems(Ability.self, urls: urls, limit: pageInfo.limit, offset: pageInfo.offset)
            self.values.append(contentsOf: abilities)
            self.pageInfo.updateOffset()
            self.pageInfo.hasNextPage = abilities.count == pageInfo.limit
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
}
