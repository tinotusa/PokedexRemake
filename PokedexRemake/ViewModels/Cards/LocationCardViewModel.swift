//
//  LocationCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for LocationCard.
final class LocationCardViewModel: ObservableObject {
    /// The location to be displayed.
    private var location: Location
    /// The loading state for the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The Region of the location.
    @Published private var region: Region?
    /// The localised name of the location.
    @Published private(set) var locationName = "Error"
    /// The localised name of the region.
    @Published private(set) var regionName = "Error"
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "LocationCardViewModel")
    
    /// Creates the view model.
    /// - Parameter location: The location to be displayed.
    init(location: Location) {
        self.location = location
    }
}

extension LocationCardViewModel {
    
    /// Loads the relevant data for the Location.
    /// - Parameter location: The Location to load data from.
    @MainActor
    func loadData(languageCode: String) async {
        logger.debug("Loading data for location with id: \(self.location.id).")
        
        guard let region = location.region else {
            logger.debug("Region is nil.")
            viewLoadingState = .loaded
            return
        }
        
        do {
            let region = try await Region(region.url)
            self.region = region
            locationName = location.localizedName(languageCode: languageCode)
            regionName = region.localizedName(languageCode: languageCode)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data for location with id: \(self.location.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
//    func localizedRegionName(languageCode: String) -> String? {
//        guard let region else {
//            logger.debug("Region is nil.")
//            return nil
//        }
//        return region.names.localizedName(language: languageCode, default: region.name)
//    }
}
