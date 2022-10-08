//
//  EvolutionDetailViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 8/10/2022.
//

import SwiftUI
import SwiftPokeAPI
import os

final class EvolutionDetailViewModel: ObservableObject {
    @Published private(set) var evolutionDetails = [EvolutionDetailKey: String]()
    @Published private(set) var item: Item?
    @Published private(set) var evolutionTrigger: EvolutionTrigger?
    @Published private(set) var heldItem: Item?
    @Published private(set) var knownMove: Move?
    @Published private(set) var knownMoveType: `Type`?
    @Published private(set) var location: Location?
    @Published private(set) var partySpecies: PokemonSpecies?
    @Published private(set) var partyType: `Type`?
    @Published private(set) var tradeSpecies: PokemonSpecies?
    
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "EvolutionDetailViewModel")
    
    enum EvolutionDetailKey: String, CaseIterable, Identifiable {
        case trigger
        case item
        case gender
        case heldItem = "held item"
        case knownMove = "known move"
        case knownMoveType = "known move type"
        case location
        case minLevel = "min level"
        case minHappiness = "min happiness"
        case minBeauty = "min beauty"
        case minAffection = "min affection"
        case needsOverworldRain = "with overworld rain"
        case partySpecies = "party species"
        case partyType = "party type"
        case relativePhysicalStats = "stats"
        case timeOfDay = "time of day"
        case tradeSpecies = "trade species"
        case turnUpsideDown = "turn upside down"
        
        var id: Self { self }
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.localizedCapitalized)
        }
    }
}

extension EvolutionDetailViewModel {
    @MainActor
    func loadData(evolutionDetail: EvolutionDetail, language: String) async {
        if let item = evolutionDetail.item,
           let itemName = item.name
        {
            await getItem(named: itemName)
        }
        if let triggerName = evolutionDetail.trigger.name {
            await getEvolutionTrigger(named: triggerName)
        }
        if let heldItem = evolutionDetail.heldItem,
           let heldItemName = heldItem.name
        {
            await getHeldItem(named: heldItemName)
        }
        if let knownMove = evolutionDetail.knownMove,
           let knownMoveName = knownMove.name
        {
            await getKnownMove(named: knownMoveName)
        }
        if let knownMoveType = evolutionDetail.knownMoveType,
           let knownMoveTypeName = knownMoveType.name
        {
            self.knownMoveType = await getType(named: knownMoveTypeName)
        }
        if let location = evolutionDetail.location,
           let locationName = location.name
        {
            await getLocation(named: locationName)
        }
        if let partySpecies = evolutionDetail.partySpecies,
           let partySpeciesName = partySpecies.name
        {
            self.partySpecies = await getPokemonSpecies(named: partySpeciesName)
        }
        if let partyType = evolutionDetail.partyType,
           let partyTypeName = partyType.name
        {
            self.partyType = await getType(named: partyTypeName)
        }
        if let tradeSpecies = evolutionDetail.tradeSpecies,
           let tradeSpeciesName = tradeSpecies.name
        {
            self.tradeSpecies = await getPokemonSpecies(named: tradeSpeciesName)
        }
        
        self.evolutionDetails = getEvolutionDetails(evolutionDetail: evolutionDetail, language: language)
        viewLoadingState = .loaded
    }
    
    func getEvolutionDetails(evolutionDetail: EvolutionDetail, language: String) -> [EvolutionDetailKey: String] {
        var details = [EvolutionDetailKey: String]()
        
        if let item {
            details[.item] = item.localizedName(for: language)
        }
        if let evolutionTrigger {
            details[.trigger] = evolutionTrigger.names.localizedName(language: language, default: evolutionTrigger.name)
        }
        if let gender = evolutionDetail.gender {
            switch gender {
            case 1: details[.gender] = "female"
            case 2: details[.gender] = "male"
            case 3: details[.gender] = "genderless"
            default: details[.gender] = "error"
            }
        }
        if let heldItem {
            details[.heldItem] = heldItem.localizedName(for: language)
        }
        if let knownMove {
            details[.knownMove] = knownMove.names.localizedName(language: language, default: knownMove.name)
        }
        if let knownMoveType {
            details[.knownMoveType] = knownMoveType.localizedName(for: language)
        }
        if let location {
            details[.location] = location.names.localizedName(language: language, default: location.name)
        }
        if let minLevel = evolutionDetail.minLevel {
            details[.minLevel] = "\(minLevel)"
        }
        if let minHappiness = evolutionDetail.minHappiness {
            details[.minHappiness] = "\(minHappiness)"
        }
        if let minBeauty = evolutionDetail.minBeauty {
            details[.minBeauty] = "\(minBeauty)"
        }
        if let minAffection = evolutionDetail.minAffection {
            details[.minAffection] = "\(minAffection)"
        }
        if evolutionDetail.needsOverworldRain {
            details[.needsOverworldRain] = "Yes"
        }
        if let partySpecies {
            details[.partySpecies] = partySpecies.localizedName(for: language)
        }
        if let partyType {
            details[.partyType] = partyType.localizedName(for: language)
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
            details[.timeOfDay] = evolutionDetail.timeOfDay
        }
        if evolutionDetail.turnUpsideDown {
            details[.turnUpsideDown] = "Yes"
        }
        return details
    }
}

private extension EvolutionDetailViewModel {
    @MainActor
    func getItem(named name: String) async {
        do {
            self.item = try await Item(name)
        } catch {
            logger.error("Failed to get item with name: \(name). \(error)")
        }
    }
    
    @MainActor
    func getEvolutionTrigger(named name: String) async {
        do {
            self.evolutionTrigger = try await EvolutionTrigger(name)
        } catch {
            logger.error("Failed to get evolution trigger with name: \(name). \(error)")
        }
    }
    
    @MainActor
    func getHeldItem(named name: String) async {
        do {
            self.heldItem = try await Item(name)
        } catch {
            logger.error("Failed to get held item with name: \(name). \(error)")
        }
    }
    
    @MainActor
    func getKnownMove(named name: String) async {
        do {
            self.knownMove = try await Move(name)
        } catch {
            logger.error("Failed to get know move with name: \(name). \(error)")
        }
    }
    
    @MainActor
    func getType(named name: String) async -> `Type`? {
        do {
            return try await Type(name)
        } catch {
            logger.error("Failed to get know move type with name: \(name). \(error)")
            return nil
        }
    }
    
    @MainActor
    func getLocation(named name: String) async {
        do {
            self.location = try await Location(name)
        } catch {
            logger.error("Failed to get location with name: \(name). \(error)")
        }
    }
    
    @MainActor
    func getPokemonSpecies(named name: String) async -> PokemonSpecies? {
        do {
            return try await PokemonSpecies(name)
        } catch {
            logger.error("Failed to get party species with name: \(name). \(error)")
            return nil
        }
    }
}
