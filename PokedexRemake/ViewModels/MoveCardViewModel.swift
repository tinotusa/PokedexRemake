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
    /// The DamageClass of the Move.
    @Published private(set) var damageClass: MoveDamageClass?
    /// The Type of the Move.
    @Published private(set) var type: `Type`?
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading

    @Published private(set) var localizedDamageClassname = "Error"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveCardViewModel")
}

extension MoveCardViewModel {
    @MainActor
    /// Loads the required data for the view.
    /// - Parameters:
    ///   - move: The Move to load data from.
    ///   - languageCode: The language code used for localisation.
    func loadData(move: Move, languageCode: String) async {
        logger.debug("Loading data for move with id: \(move.id).")
        do {
            async let damageClass = MoveDamageClass(move.damageClass.url)
            async let type = Type(move.type.url)
            
            self.damageClass = try await damageClass
            self.type = try await type
            localizedDamageClassname = try await damageClass.localizedName(languageCode: languageCode)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data for move with id: \(move.id).")
        } catch {
            logger.error("Failed to load data for move with id: \(move.id). \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
