//
//  LocationDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 30/10/2022.
//

import Foundation
import SwiftPokeAPI
import os


final class LocationDetailViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The Region of the Location.
    @Published private(set) var region: Region?
    /// The LocationAreas of the Location.
    @Published private(set) var areas = [LocationArea]()
    
    private let logger = Logger(subsystem: "com.tinotusa.Pokedex", category: "LocationDetailViewModel")
}

extension LocationDetailViewModel {
    /// Loads the details for the Location.
    /// - Parameter location: The location to load data from.
    @MainActor
    func loadData(location: Location) async {
        logger.debug("Loading data for location with id: \(location.id).")
        do {
            if let region = location.region {
                self.region = try await Region(region.url)
            }
            self.areas = try await Globals.getItems(LocationArea.self, urls: location.areas.urls()).sorted()
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for location with id: \(location.id).")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data for location with id: \(location.id). \(error)")
        }
    }
}
