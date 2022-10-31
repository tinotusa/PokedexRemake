//
//  LocationAreaDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 31/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class LocationAreaDetailViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var encounterVersions = [EncounterVersion]()
    @Published var showingPokemonList = false
    
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "LocationAreaDetailViewModel")
    
    struct EncounterVersion: Identifiable {
        let id = UUID().uuidString
        let encounterMethod: EncounterMethod
        let versionDetails: [(rate: Int, version: Version)]
    }
}

extension LocationAreaDetailViewModel {
    @MainActor
    func loadData(locationArea: LocationArea) async {
        do {
            self.encounterVersions = try await getEncounterMethodVersions(locationArea: locationArea)
            
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    func getEncounterMethodVersions(locationArea: LocationArea) async throws -> [EncounterVersion] {
        try await withThrowingTaskGroup(of: EncounterVersion.self) { group in
            for method in locationArea.encounterMethodRates {
                group.addTask {
                    let encounterMethod = try await EncounterMethod(method.encounterMethod.url)
                    var versionDetails = [(rate: Int, version: Version)]()
                    for test in method.versionDetails {
                        let version = try await Version(test.version.url)
                        versionDetails.append((rate: test.rate, version: version))
                    }
                    return EncounterVersion(encounterMethod: encounterMethod, versionDetails: versionDetails)
                }
            }
            var encounterVersions = [EncounterVersion]()
            for try await encounterVersion in group {
                encounterVersions.append(encounterVersion)
            }
            return encounterVersions
        }
    }
}
