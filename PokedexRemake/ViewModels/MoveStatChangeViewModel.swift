//
//  MoveStatChangeViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

/// View model for MoveStatChangeView.
final class MoveStatChangeViewModel: ObservableObject {
    /// The stat change to display.
    private var moveStatChange: MoveStatChange
    /// The stat of the move.
    @Published private(set) var stat: Stat?
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The localised name of the Stat.
    @Published private(set) var statName = "Error"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveStatChangeViewModel")
    
    /// Creates the view model
    /// - Parameter moveStatChange: The MoveStatChange to display.
    init(moveStatChange: MoveStatChange) {
        self.moveStatChange = moveStatChange
    }
}

extension MoveStatChangeViewModel {
    @MainActor
    /// Loads the stat for the MoveStatChange.
    /// - Parameter statChange: The MoveStatChange to load the Stat from.
    func loadData(languageCode: String) async {
        logger.debug("Loading data.")
        do {
            let stat = try await Stat(moveStatChange.stat.url)
            self.stat = stat
            statName = stat.localizedName(languageCode: languageCode)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
