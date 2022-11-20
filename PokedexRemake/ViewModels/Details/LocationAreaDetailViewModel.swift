//
//  LocationAreaDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 31/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View Model for LocationAreaDetail
final class LocationAreaDetailViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The EncounterVersions of the LocationArea.
    @Published private(set) var encounterVersions = [EncounterVersion]()
    /// A Boolean value indicating whether or not the pokemon list view is showing.
    @Published var showingPokemonList = false
    
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "LocationAreaDetailViewModel")
    
    /// A struct to hold the encounter method and its version details.
    struct EncounterVersion: Identifiable {
        /// A unique identifier for the encounter version.
        let id = UUID().uuidString
        /// The EncounterMethod.
        let encounterMethod: EncounterMethod
        typealias VersionRate = (version: Version, rate: Int)
        /// The rate and Version of the encounter.
        let versionDetails: [VersionRate]
    }
}

extension LocationAreaDetailViewModel {
    @MainActor
    /// Loads the data for the view.
    /// - Parameter locationArea: The LocationArea to load data from.
    func loadData(locationArea: LocationArea) async {
        logger.debug("Loading data for location area with id: \(locationArea.id).")
        do {
            self.encounterVersions = try await getEncounterMethodVersions(locationArea: locationArea)
            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for location area with id: \(locationArea.id).")
        } catch {
            viewLoadingState = .error(error: error)
            logger.debug("Failed to load data for location area with id: \(locationArea.id). \(error)")
        }
    }
}

private extension LocationAreaDetailViewModel {
    /// Returns an array of EncounterVersions.
    /// - Parameter locationArea: The LocationArea to fetch EncounterMethods from.
    /// - Returns: An array of EncounterVersions.
    func getEncounterMethodVersions(locationArea: LocationArea) async throws -> [EncounterVersion] {
        logger.debug("Getting encounter versions.")
        return try await withThrowingTaskGroup(of: EncounterVersion.self) { group in
            for method in locationArea.encounterMethodRates {
                group.addTask {
                    let encounterMethod = try await EncounterMethod(method.encounterMethod.url)
                    var versionDetails = [EncounterVersion.VersionRate]()
                    for test in method.versionDetails {
                        let version = try await Version(test.version.url)
                        versionDetails.append((version: version, rate: test.rate))
                    }
                    return EncounterVersion(encounterMethod: encounterMethod, versionDetails: versionDetails)
                }
            }
            
            var encounterVersions = [EncounterVersion]()
            for try await encounterVersion in group {
                encounterVersions.append(encounterVersion)
            }
            logger.debug("Successfully got encounter versions for location area with id: \(locationArea.id).")
            return encounterVersions
        }
    }
}
