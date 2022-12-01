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

/// View model for MoveDetail.
final class MoveDetailViewModel: ObservableObject {
    /// The move to be displayed.
    private var move: Move
    /// The loading state for the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The type of the Move to be displayed.
    @Published private(set) var type: `Type`?
    /// The damageClass of the Move to be displayed.
    @Published private(set) var damageClass: MoveDamageClass?
    /// The moveTarget of the Move to be displayed.
    @Published private(set) var moveTarget: MoveTarget?
    /// The generation of the Move to be displayed.
    @Published private(set) var generation: Generation?
    /// The ailment of the Move to be displayed.
    @Published private(set) var ailment: MoveAilment?
    /// The category of the Move to be displayed.
    @Published private(set) var category: MoveCategory?
    
    @Published private(set) var localizedFlavorTextEntries = [MoveFlavorText]()
    /// The moveDetails of the Move.
    @Published private(set) var moveDetails = [MoveDetails: String]()
    /// The metaDetails of the Move.
    @Published private(set) var metaDetails = [MoveMetaDetails: String]()
    /// The localised name of the move.
    @Published private(set) var moveName = "Error"
    /// The flavour texts of the move.
    @Published private(set) var customFlavorTexts = [CustomFlavorText]()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveDetailViewModel")
    
    /// Creates the view model.
    /// - Parameter move: The move to be displayed.
    init(move: Move) {
        self.move = move
    }
    
    /// The move detail keys.
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
        
        /// A unique identifier for the key.
        var id: Self { self }
        
        /// A title for the key.
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
    
    /// The move meta detail keys.
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
        
        /// A unique identifier for the key.
        var id: Self { self }
        
        /// A localised title for the key.
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
}

extension MoveDetailViewModel {
    /// Loads the relevant data for a Move.
    /// - Parameters:
    ///   - move: The move to load data from.
    ///   - languageCode: The language code used for localisation.
    @MainActor
    func loadData(languageCode: String) async {
        logger.debug("Loading data.")
        do {
            try await withThrowingTaskGroup(of: Void.self) { (group) -> Void in
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    self.type = try await `Type`(self.move.type.url)
                }
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    self.damageClass = try await MoveDamageClass(self.move.damageClass.url)
                }
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    self.moveTarget = try await MoveTarget(self.move.target.url)
                }
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    self.generation = try await Generation(self.move.generation.url)
                }
                
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    if let meta = self.move.meta {
                        self.ailment = try await MoveAilment(meta.ailment.url)
                    }
                }
                group.addTask { @MainActor [weak self] in
                    guard let self else { return }
                    if let meta = self.move.meta {
                        self.category = try await MoveCategory(meta.category.url)
                    }
                }
                
                try await group.waitForAll()
            }
            
            self.localizedFlavorTextEntries = move.flavorTextEntries.localizedItems(for: languageCode)
            self.moveDetails = getMoveDetails(move: move, languageCode: languageCode)
            self.metaDetails = getMoveMetaDetails(move: move, languageCode: languageCode)
            self.moveName = move.localizedName(languageCode: languageCode)
            self.customFlavorTexts = localizedFlavorTextEntries.map { entry in
                CustomFlavorText(
                    flavorText: entry.filteredFlavorText(),
                    language: entry.language,
                    versionGroup: entry.versionGroup
                )
            }
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to  load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}

private extension MoveDetailViewModel {
    /// Returns the move details in key value pairs.
    /// - Parameters:
    ///   - move: The Move to get detail from.
    ///   - languageCode: The language code used for localisations.
    /// - Returns: A dictionary of MoveDetailKeys and Strings.
    func getMoveDetails(move: Move, languageCode: String) -> [MoveDetails: String] {
        var moveDetails = [MoveDetails: String]()
        if let name = move.type.name {
            moveDetails[.type] = name
        }
        if let damageClass {
            moveDetails[.damageClass] = damageClass.localizedName(languageCode: languageCode)
        }
        if let moveTarget {
            moveDetails[.target] = moveTarget.localizedName(languageCode: languageCode)
        }
        if let accuracy = move.accuracy {
            moveDetails[.accuracy] = accuracy.formatted(.percent)
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
            moveDetails[.generation] = generation.localizedName(languageCode: languageCode)
        }
        moveDetails[.learnedByPokemon] = "\(move.learnedByPokemon.count)"
        moveDetails[.effectEntries] = "\(move.effectEntries.count)"
        moveDetails[.effectChanges] = "\(move.effectChanges.count)"
        moveDetails[.flavorTextEntries] = "\(localizedFlavorTextEntries.count)"
        moveDetails[.machines] = "\(move.machines.count)"
        moveDetails[.pastValues] = "\(move.pastValues.count)"
        moveDetails[.statChanges] = "\(move.statChanges.count)"
        
        return moveDetails
    }
    
    /// Returns the move meta details in a dictionary.
    /// - Parameters:
    ///   - move: The Move to get the meta details from.
    ///   - languageCode: The language code used for localisations.
    /// - Returns: A dictionary of MoveMetaDetails and Strings.
    func getMoveMetaDetails(move: Move, languageCode: String) -> [MoveMetaDetails: String] {
        var metaDetails = [MoveMetaDetails: String]()
        guard let meta = move.meta else {
            return [:]
        }
        if let ailment {
            metaDetails[.ailment] = ailment.localizedName(languageCode: languageCode)
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
