//
//  MoveCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for MoveCard.
final class MoveCardViewModel: ObservableObject {
    /// The move to load data from.
    private var move: Move
    /// The DamageClass of the Move.
    @Published private(set) var damageClass: MoveDamageClass?
    /// The Type of the Move.
    @Published private(set) var type: `Type`?
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The localised damage class name of the Move.
    @Published private(set) var localizedDamageClassname = "Error"
    /// The localised name of the move.
    @Published private(set) var localizedMoveName = "Error"
    /// The localised effect entry of the move.
    @Published private(set) var localizedEffectEntry = "Error"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveCardViewModel")
    
    /// Creates a move card.
    /// - Parameters:
    ///   - move: The move to load data from.
    init(move: Move) {
        self.move = move
    }
}

extension MoveCardViewModel {
    @MainActor
    /// Loads the required data for the view.
    /// - Parameter languageCode: The language code used for localisations.
    func loadData(languageCode: String) async {
        logger.debug("Loading data for move with id: \(self.move.id).")
        do {
            async let damageClass = MoveDamageClass(move.damageClass.url)
            async let type = Type(move.type.url)
            
            self.damageClass = try await damageClass
            self.type = try await type
            localizedDamageClassname = try await damageClass.localizedName(languageCode: languageCode)
            localizedMoveName = move.localizedName(languageCode: languageCode)
            localizedEffectEntry = move.localizedEffectEntry(
                for: languageCode,
                shortVersion: true,
                effectChance: move.effectChance
            )
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for move with id: \(self.move.id).")
        } catch {
            logger.error("Failed to load data for move with id: \(self.move.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
