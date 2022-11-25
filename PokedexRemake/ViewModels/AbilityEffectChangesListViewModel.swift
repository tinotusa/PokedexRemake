//
//  AbilityEffectChangesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

struct LocalizedEffectsWithVersion: Identifiable {
    let id = UUID().uuidString
    let effectEntries: [Effect]
    let versions: [Version]
}

/// View model for AbilityEffectChangesList.
final class AbilityEffectChangesListViewModel: ObservableObject {
    /// The localised effects of an Ability.
    @Published private(set) var localizedEffects = [AbilityEffectChange]()
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The localised effect versions of an Ability.
    @Published private(set) var localizedEffectVersions = [LocalizedEffectsWithVersion]()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityEffectChangesListViewModel")
}

extension AbilityEffectChangesListViewModel {
    /// Loads the relevant data from the given effect changes.
    /// - Parameters:
    ///   - effectChanges: An array of AbilityEffectChange to load data from.
    ///   - languageCode: The language code used for localisations.
    @MainActor
    func loadData(effectChanges: [AbilityEffectChange], languageCode: String) async {
        logger.debug("Loading data.")
        let availableLanguages = effectChanges.flatMap { $0.effectEntries.compactMap { $0.language.name } }
        let deviceLanguageCode = Bundle.preferredLocalizations(from: availableLanguages, forPreferences: nil).first!
        do {
            for effectChange in effectChanges {
                var effects = [Effect]()
                for effect in effectChange.effectEntries {
                    if effect.language.name == languageCode {
                        effects.append(effect)
                    } else if effect.language.name == deviceLanguageCode {
                        effects.append(effect)
                    } else if effect.language.name == "en" {
                        effects.append(effect)
                    }
                }
                let versionGroup = try await VersionGroup(effectChange.versionGroup.url)
                let versions = try await Globals.getItems(Version.self, urls: versionGroup.versions.map { $0.url })
                localizedEffectVersions.append(.init(effectEntries: effects, versions: Array(versions)))
            }
            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            viewLoadingState = .error(error: error)
            logger.error("Failed to load data. \(error)")
        }
    }
}
