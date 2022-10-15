//
//  AbilitiesCategoryViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 15/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class AbilitiesCategoryViewModel: ObservableObject, Identifiable {
    let id = UUID().uuidString
    @Published private var abilities = Set<Ability>()
    @Published private(set) var hasNextPage = true
    @Published private(set) var nextPageURL: URL? {
        didSet {
            if nextPageURL == nil { hasNextPage = false }
        }
    }
    
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilitiesCategoryViewModel")
}

extension AbilitiesCategoryViewModel {
    func sortedAbilities() -> [Ability] {
        self.abilities.sorted()
    }
    
    @MainActor
    func loadData() async {
        do {
            let resource = try await Resource<Ability>(limit: 20)
            self.abilities = resource.items
            self.nextPageURL = resource.next
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func loadNextPage() async {
        logger.debug("Loading next page.")
        guard let nextPageURL else {
            logger.error("Failed to load next page. nextPageURL is nil.")
            return
        }
        do {
            let resource = try await Resource<Ability>(nextPageURL)
            self.abilities.formUnion(resource.items)
            self.nextPageURL = resource.next
            logger.debug("Successfully loaded next page.")
            print(self.abilities.count)
        } catch {
            logger.error("Failed to load next page. \(error)")
        }
    }
}

extension AbilitiesCategoryViewModel: Hashable {
    static func == (lhs: AbilitiesCategoryViewModel, rhs: AbilitiesCategoryViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
