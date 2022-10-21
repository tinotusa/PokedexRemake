//
//  MoveDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import Foundation
import SwiftUI
import SwiftPokeAPI
import os

final class MoveDetailViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var type: `Type`?
    @Published private(set) var damageClass: MoveDamageClass?
    @Published private(set) var moveTarget: MoveTarget?
    @Published private(set) var generation: Generation?
    @Published private(set) var ailment: MoveAilment?
    @Published private(set) var category: MoveCategory?
    
    @Published private(set) var moveDetails = [MoveDetails: String]()
    @Published private(set) var metaDetails = [MoveMetaDetails: String]()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveDetailViewModel")

    enum MoveDetails: String, CaseIterable, Identifiable {
        case type
        case damageClass = "damage class"
        case target
        case accuracy
        case effectChance = "effect chance"
        case pp
        case priority
        case power
        case generation
        case learnedByPokemon = "learned by pokemon"
        case effectEntries = "effect entries"
        case effectChanges = "effect changes"
        case flavorTextEntries = "flavor text"
        case machines
        case pastValues = "past values"
        case statChanges = "stat changes"
        
        var id: Self { self }
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
    
    enum MoveMetaDetails: String, CaseIterable, Identifiable {
        case ailment
        case category
        case minHits = "min hits"
        case maxHits = "max hits"
        case minTurns = "min turns"
        case maxTurns = "max turns"
        case drain
        case healing
        case critRate = "crit rate"
        case ailmentChance = "ailment chance"
        case flinchChance = "flinch chance"
        case statChance = "stat chance"
        
        var id: Self { self }
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
}

extension MoveDetailViewModel {
    @MainActor
    func loadData(move: Move, languageCode: String) async {
        logger.debug("Loading data.")
        do {
            // TODO: Add async lets to help speed this up
            self.type = try await `Type`(move.type.url)
            self.damageClass = try await MoveDamageClass(move.damageClass.url)
            self.moveTarget = try await MoveTarget(move.target.url)
            self.generation = try await Generation(move.generation.url)
            if let meta = move.meta {
                self.ailment = try await MoveAilment(meta.ailment.url)
                self.category = try await MoveCategory(meta.category.url)
            }
            self.moveDetails = getMoveDetails(move: move, languageCode: languageCode)
            self.metaDetails = getMoveMetaDetails(move: move, languageCode: languageCode)
//            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to  load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}

private extension MoveDetailViewModel {
    func getMoveDetails(move: Move, languageCode: String) -> [MoveDetails: String] {
        var moveDetails = [MoveDetails: String]()
        if let name = move.type.name {
            moveDetails[.type] = name
        }
        if let damageClass {
            moveDetails[.damageClass] = damageClass.localizedName(for: languageCode)
        }
        if let moveTarget {
            moveDetails[.target] = moveTarget.names.localizedName(language: languageCode, default: moveTarget.name)
        }
        if let accurary = move.accuracy {
            moveDetails[.accuracy] = accurary.formatted(.percent)
        }
        if let effectChance = move.effectChance {
            moveDetails[.effectChance] = effectChance.formatted(.percent)
        }
        moveDetails[.pp] = "\(move.pp)"
        moveDetails[.priority] = "\(move.priority)"
        if let power = move.power {
            moveDetails[.power] = "\(power)"
        }
        if let generation {
            moveDetails[.generation] = generation.localizedName(for: languageCode)
        }
        moveDetails[.learnedByPokemon] = "\(move.learnedByPokemon.count)"
        moveDetails[.effectEntries] = "\(move.effectEntries.count)"
        moveDetails[.effectChanges] = "\(move.effectChanges.count)"
        moveDetails[.flavorTextEntries] = "\(move.flavorTextEntries.count)" // TODO: get only the localized entries count
        moveDetails[.machines] = "\(move.machines.count)"
        moveDetails[.pastValues] = "\(move.pastValues.count)"
        moveDetails[.statChanges] = "\(move.statChanges.count)"
        
        return moveDetails
    }
    
    func getMoveMetaDetails(move: Move, languageCode: String) -> [MoveMetaDetails: String] {
        var metaDetails = [MoveMetaDetails: String]()
        guard let meta = move.meta else {
            return [:]
        }
        if let ailment {
            metaDetails[.ailment] = ailment.names.localizedName(language: languageCode, default: ailment.name)
        }
        if let category {
            metaDetails[.category] = category.name
        }
        if let minHits = meta.minHits {
            metaDetails[.minHits] = "\(minHits)"
        }
        if let maxHits = meta.maxHits {
            metaDetails[.maxHits] = "\(maxHits)"
        }
        if let minTurns = meta.minTurns {
            metaDetails[.minTurns] = "\(minTurns)"
        }
        metaDetails[.drain] = "\(meta.drain)"
        metaDetails[.healing] = "\(meta.healing)"
        metaDetails[.critRate] = meta.critRate.formatted(.percent)
        metaDetails[.ailmentChance] = meta.ailmentChance.formatted(.percent)
        metaDetails[.flinchChance] = meta.flinchChance.formatted(.percent)
        metaDetails[.statChance] = meta.statChance.formatted(.percent)
        return metaDetails
    }
}
