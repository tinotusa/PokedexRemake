//
//  MoveStatChangeViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class MoveStatChangeViewModel: ObservableObject {
    @Published private(set) var stat: Stat?
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveStatChangeViewModel")
}

extension MoveStatChangeViewModel {
    @MainActor
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
