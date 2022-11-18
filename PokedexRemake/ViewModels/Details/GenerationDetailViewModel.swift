//
//  GenerationDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 1/11/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

final class GenerationDetailViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var mainRegion: Region?
    @Published private var versionGroups = [VersionGroup]()
    @Published private(set) var versions = [Version]()
    @Published private(set) var types = [`Type`]()
    
    @Published private(set) var details = [InfoKey: String]()
    
    @Published var showingMovesList = false
    @Published var showingPokemonSpeciesList = false
    @Published var showingAbilitiesList = false
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "GenerationDetailViewModel")
    
    enum InfoKey: String, CaseIterable, Identifiable {
        case abilities
        case mainRegion = "main region"
        case moves
        case pokemonSpecies = "pokemon species"
        case types
        case versionGroups = "version groups"
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
        
        var id: Self { self }
    }
}

extension GenerationDetailViewModel {
    @MainActor
    func loadData(generation: Generation, languageCode: String) async {
        do {
            self.mainRegion = try await Region(generation.mainRegion.url)
            let versionGroups = try await Globals.getItems(VersionGroup.self, urls: generation.versionGroups.map { $0.url })
            self.versionGroups.append(contentsOf: versionGroups)
            let versions = try await Globals.getItems(Version.self, urls: versionGroups.flatMap { $0.versions.map { $0.url } }).sorted()
            self.versions.append(contentsOf: versions)
            
            let types = try await Globals.getItems(`Type`.self, urls: generation.types.map { $0.url }).sorted()
            self.types.append(contentsOf: types)
            self.details = getGenerationDetails(generation: generation, languageCode: languageCode)
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    func getGenerationDetails(generation: Generation, languageCode: String) -> [InfoKey: String] {
        var details = [InfoKey: String]()
        
        details[.abilities] = "\(generation.abilities.count)"
        if let mainRegion {
            details[.mainRegion] = mainRegion.localizedName(languageCode: languageCode)
        }
        details[.moves] = "\(generation.moves.count)"
        details[.pokemonSpecies] = "\(generation.pokemonSpecies.count)"
        details[.types] = "\(generation.types.count)"
        details[.versionGroups] = "\(generation.versionGroups.count)"
        
        return details
    }
}
