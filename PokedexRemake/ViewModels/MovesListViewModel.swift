//
//  MovesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import Foundation
import SwiftPokeAPI
import os
final class MovesListViewModel: ObservableObject {
    @Published private(set) var pokemonSpecies: PokemonSpecies!
    @Published private var moves = Set<Move>()
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MovesTabViewModel")
}

extension MovesListViewModel {
    @MainActor
    func loadData(pokemon: Pokemon) async {
        logger.debug("Loading data.")
        do {
            self.moves = try await Globals.getMoves(urls: pokemon.moves.map { $0.move.url })
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed load data.")
            viewLoadingState = .error(error: error)
        }
    }
    
    func sortedMoves() -> [Move] {
        moves.sorted()
    }
}
