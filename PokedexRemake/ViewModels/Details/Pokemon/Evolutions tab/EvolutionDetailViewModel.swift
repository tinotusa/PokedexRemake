//
//  EvolutionDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 8/10/2022.
//

import SwiftUI
import SwiftPokeAPI
import os

/// View model for EvolutionDetailView.
final class EvolutionDetailViewModel: ObservableObject {
    /// Evolution details for a Pokemon.
    @Published private(set) var evolutionDetails = [EvolutionDetailKey: String]()
    /// The item required for evolution.
    @Published private(set) var item: Item?
    /// The evolutionTrigger required for evolution.
    @Published private(set) var evolutionTrigger: EvolutionTrigger?
    /// The Item required for evolution.
    @Published private(set) var heldItem: Item?
    /// The knownMove required for evolution.
    @Published private(set) var knownMove: Move?
    /// The knownMoveType required for evolution.
    @Published private(set) var knownMoveType: `Type`?
    /// The location required for evolution.
    @Published private(set) var location: Location?
    /// The partySpecies required for evolution.
    @Published private(set) var partySpecies: PokemonSpecies?
    /// The partyType required for evolution.
    @Published private(set) var partyType: `Type`?
    /// The tradeSpecies required for evolution.
    @Published private(set) var tradeSpecies: PokemonSpecies?
    
    /// The loading state for the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "EvolutionDetailViewModel")
    
    /// The Evolution trigger keys
    enum EvolutionDetailKey: CaseIterable, Identifiable {
        case trigger
        case minLevel
        case item
        case heldItem
        case knownMove
        case knownMoveType
        case location
        case gender
        case minHappiness
        case minBeauty
        case minAffection
        case needsOverworldRain
        case partySpecies
        case partyType
        case relativePhysicalStats
        case timeOfDay
        case tradeSpecies
        case turnUpsideDown
        
        var id: Self { self }
    }
    
    enum EvolutionDetailError: Error {
        case loadingFailed(error: Error)
    }
}

extension EvolutionDetailViewModel {
    /// Loads the relevant data for the view.
    /// - Parameters:
    ///   - evolutionDetail: The EvolutionDetail to load data from.
    ///   - language: The language code used for localisation.
    @MainActor
    func loadData(evolutionDetail: EvolutionDetail, language: String) async {
        do {
            if let item = evolutionDetail.item {
                self.item = try await Item(item.url)
            }
            self.evolutionTrigger = try await EvolutionTrigger(evolutionDetail.trigger.url)
            
            if let heldItem = evolutionDetail.heldItem {
                self.heldItem = try  await Item(heldItem.url)
            }
            if let knownMove = evolutionDetail.knownMove
            {
                self.knownMove = try await Move(knownMove.url)
            }
            if let knownMoveType = evolutionDetail.knownMoveType {
                self.knownMoveType = try await `Type`(knownMoveType.url)
            }
            if let location = evolutionDetail.location {
                self.location = try await Location(location.url)
            }
            if let partySpecies = evolutionDetail.partySpecies {
                self.partySpecies = try await PokemonSpecies(partySpecies.url)
            }
            if let partyType = evolutionDetail.partyType {
                self.partyType = try await `Type`(partyType.url)
            }
            if let tradeSpecies = evolutionDetail.tradeSpecies {
                self.tradeSpecies = try await PokemonSpecies(tradeSpecies.url)
            }
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: EvolutionDetailError.loadingFailed(error: error))
            return
        }
        
        self.evolutionDetails = getEvolutionDetails(evolutionDetail: evolutionDetail, language: language)
        viewLoadingState = .loaded
    }
    
    /// Returns a dictionary of EvolutionDetailKeys and Strings.
    /// - Parameters:
    ///   - evolutionDetail: The EvolutionDetail to get the values from.
    ///   - language: The language code used for localisations.
    /// - Returns: A dictionary of EvolutionDetailKeys and values.
    func getEvolutionDetails(evolutionDetail: EvolutionDetail, language: String) -> [EvolutionDetailKey: String] {
        var details = [EvolutionDetailKey: String]()
        
        if let item {
            details[.item] = item.localizedName(languageCode: language)
        }
        if let evolutionTrigger {
            details[.trigger] = evolutionTrigger.localizedName(languageCode: language)
        }
        if let gender = evolutionDetail.gender {
            switch gender {
            case 1: details[.gender] = "(Female)"
            case 2: details[.gender] = "(Male)"
            case 3: details[.gender] = "genderless"
            default: details[.gender] = "error"
            }
        }
        if let heldItem {
            details[.heldItem] = "Holding \(heldItem.localizedName(languageCode: language))"
        }
        if let knownMove {
            details[.knownMove] = "Learning \(knownMove.localizedName(languageCode: language))"
        }
        if let knownMoveType {
            details[.knownMoveType] = "Learning \(knownMoveType.localizedName(languageCode: language)) type move"
        }
        if let location {
            details[.location] = "At \(location.localizedName(languageCode: language))"
        }
        if let minLevel = evolutionDetail.minLevel {
            details[.minLevel] = "Level \(minLevel)+"
        }
        if let minHappiness = evolutionDetail.minHappiness {
            details[.minHappiness] = "Happiness \(minHappiness)+"
        }
        if let minBeauty = evolutionDetail.minBeauty {
            details[.minBeauty] = "Beauty \(minBeauty)+"
        }
        if let minAffection = evolutionDetail.minAffection {
            details[.minAffection] = "Affection \(minAffection)+"
        }
        if evolutionDetail.needsOverworldRain {
            details[.needsOverworldRain] = "While raining."
        }
        if let partySpecies {
            details[.partySpecies] = "With \(partySpecies.localizedName(languageCode: language)) in the party."
        }
        if let partyType {
            details[.partyType] = "With \(partyType.localizedName(languageCode: language)) type in the party."
        }
        if let relativePhysicalStats = evolutionDetail.relativePhysicalStats {
            switch relativePhysicalStats {
            case -1: details[.relativePhysicalStats] = "Attack < Defense"
            case 0: details[.relativePhysicalStats] = "Attack = Defense"
            case 1: details[.relativePhysicalStats] =  "Attack > Defense"
            default: details[.relativePhysicalStats] = "error"
            }
        }
        if !evolutionDetail.timeOfDay.isEmpty {
            switch evolutionDetail.timeOfDay {
            case "day": details[.timeOfDay] = "During the day"
            case "night": details[.timeOfDay] = "At night"
            case "dusk": details[.timeOfDay] = "At dusk"
            default: details[.timeOfDay] = "error"
            }
            
        }
        if evolutionDetail.turnUpsideDown {
            details[.turnUpsideDown] = "Turn upside down"
        }
        return details
    }
}
