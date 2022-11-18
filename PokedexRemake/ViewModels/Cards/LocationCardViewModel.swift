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
    /// The loading state for the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The Region of the location.
    @Published private(set) var region: Region?
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "LocationCardViewModel")
}

extension LocationCardViewModel {
    
    /// Loads the relevant data for the Location.
    /// - Parameter location: The Location to load data from.
    @MainActor
    func loadData(location: Location) async {
        logger.debug("Loading data.")
        
        guard let region = location.region else {
            logger.debug("Region is nil.")
            viewLoadingState = .loaded
            return
        }
        
        do {
            self.region = try await Region(region.url)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data for location with id: \(location.id). \(error)")
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
