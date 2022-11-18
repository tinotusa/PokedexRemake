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

final class AbilityEffectChangesListViewModel: ObservableObject {
    @Published private(set) var localizedEffects = [AbilityEffectChange]()
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var localizedEffectVersions = [LocalizedEffectsWithVersion]()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityEffectChangesListViewModel")
}

extension AbilityEffectChangesListViewModel {
    @MainActor
    func loadData(effectChanges: [AbilityEffectChange], language: String) async {
        let availableLanguages = effectChanges.flatMap { $0.effectEntries.compactMap { $0.language.name } }
        let deviceLanguageCode = Bundle.preferredLocalizations(from: availableLanguages, forPreferences: nil).first!
        do {
            for effectChange in effectChanges {
                var effects = [Effect]()
                for effect in effectChange.effectEntries {
                    if effect.language.name == language {
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
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
}
