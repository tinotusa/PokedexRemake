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
    /// The stat of the move.
    @Published private(set) var stat: Stat?
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveStatChangeViewModel")
}

extension MoveStatChangeViewModel {
    @MainActor
    /// Loads the stat for the MoveStatChange.
    /// - Parameter statChange: The MoveStatChange to load the Stat from.
    func loadData(statChange: MoveStatChange) async {
        logger.debug("Loading data.")
        do {
            self.stat = try await Stat(statChange.stat.url)
            viewLoadingState = .loaded
            logger.debug("Successfully loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
