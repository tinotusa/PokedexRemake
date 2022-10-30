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
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var region: Region?
    @Published private(set) var areas = [LocationArea]()
    private let logger = Logger(subsystem: "com.tinotusa.Pokedex", category: "LocationDetailViewModel")
}

extension LocationDetailViewModel {
    @MainActor
    func loadData(location: Location) async {
        do {
            if let region = location.region {
                self.region = try await Region(region.url)
            }
            self.areas = try await getLocationAreas(location: location)
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    func getLocationAreas(location: Location) async throws -> [LocationArea] {
        try await withThrowingTaskGroup(of: LocationArea.self) { group in
            for locationArea in location.areas {
                group.addTask {
                    return try await LocationArea(locationArea.url)
                }
            }
            
            var locationAreas = [LocationArea]()
            for try await locationArea in group {
                locationAreas.append(locationArea)
            }
            return locationAreas
        }
    }
}

