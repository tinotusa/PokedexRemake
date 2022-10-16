//
//  LocationCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class LocationCardViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var region: Region?
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "LocationCardViewModel")
}

extension LocationCardViewModel {
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
    
    func localizedRegionName(languageCode: String) -> String? {
        guard let region else {
            logger.debug("Region is nil.")
            return nil
        }
        return region.names.localizedName(language: languageCode, default: region.name)
    }
}
