//
//  AbilityDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 30/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

final class AbilityDetailViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private var generation: Generation?
    @Published private(set) var abilityDetails = [AbilityDetailKey: String]()
    
    @Published var showingEffectEntriesListView = false
    @Published var showingEffectChangesListView = false
    @Published var showingFlavorTextEntriesListView = false
    @Published var showingPokemonListView = false
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityDetailViewModel")

    enum AbilityDetailKey: String, CaseIterable, Identifiable {
        case isMainSeries = "is main series"
        case generation
        case effectEntries = "effect entries"
        case effectChanges = "effect changes"
        case flavorTextEntries = "flavor texts"
        case pokemon
        
        var id: Self { self }
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
    
}

extension AbilityDetailViewModel {
    @MainActor
    func loadData(ability: Ability, languageCode: String) async {
        do {
            self.generation = try await Generation(ability.generation.url)
            
            abilityDetails = getAbilityDetails(ability: ability, languageCode: languageCode)
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    func getAbilityDetails(ability: Ability, languageCode: String) -> [AbilityDetailKey: String] {
        var details = [AbilityDetailKey: String]()
        details[.isMainSeries] = ability.isMainSeries ? "Yes" : "No"
        if let generation {
            details[.generation] = generation.localizedName(languageCode: languageCode)
        }
        details[.effectEntries] = "\(ability.effectEntries.localizedItems(for: languageCode).count)"
        details[.effectChanges] = "\(ability.effectChanges.count)"
        details[.flavorTextEntries] = "\(ability.flavorTextEntries.localizedItems(for: languageCode).count)"
        details[.pokemon] = "\(ability.pokemon.count)"
        
        return details
    }
}
