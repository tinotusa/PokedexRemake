//
//  LocationsCategoryViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class LocationsCategoryViewModel: ObservableObject, Identifiable {
    let id = UUID().uuidString
    @Published private(set) var locations = Set<Location>()
    @Published private(set) var hasNextPage = true
    @Published private var nextPageURL: URL? {
        didSet {
            if nextPageURL == nil { hasNextPage = false }
        }
    }
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "LocationsCategoryViewModel")
}

extension LocationsCategoryViewModel: Hashable {
    static func == (lhs: LocationsCategoryViewModel, rhs: LocationsCategoryViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension LocationsCategoryViewModel {
    func sortedLocations() -> [Location] {
        self.locations.sorted()
    }
    
    @MainActor
    func loadData() async {
        do {
            let resource = try await Resource<Location>(limit: 20)
            self.locations = resource.items
            self.nextPageURL = resource.next
            viewLoadingState = .loaded
        } catch  {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func loadNextPage() async {
        guard let nextPageURL else {
            logger.error("Failed to load next page. nextPageURL is nil.")
            return
        }
        do {
            let resource = try await Resource<Location>(nextPageURL)
            self.locations.formUnion(resource.items)
            self.nextPageURL = resource.next
        } catch {
            logger.error("Failed to load next page url: \(nextPageURL). \(error)")
        }
    }
}
