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
    @Published private(set) var hasNextPage = true
    
    @Published private var moves = Set<Move>() {
        willSet {
            page += 1
            if abs(moves.count - newValue.count) < limit {
                hasNextPage = false
            }
        }
    }
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private var urls = [URL]()
    private var page = 0 {
        didSet {
            offset = page * limit
        }
    }
    private var offset = 0
    private let limit = 20
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MovesTabViewModel")
}

extension MovesListViewModel {
    @MainActor
    func loadData(pokemon: Pokemon) async {
        logger.debug("Loading data.")
        let urls = pokemon.moves.map { $0.move.url }
        self.urls = urls
        
        do {
            self.moves = try await Globals.getMoves(urls: urls, limit: limit)
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed load data.")
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func getNextPage() async {
        do {
            let moves = try await Globals.getMoves(urls: self.urls, limit: 20, offset: offset)
            self.moves.formUnion(moves)
            logger.debug("Successfully got the next page.")
        } catch {
            logger.error("Failed to get next page. \(error)")
        }
    }
    
    func sortedMoves() -> [Move] {
        moves.sorted()
    }
}
