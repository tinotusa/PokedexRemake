//
//  MoveCategoryViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 14/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class MoveCategoryViewModel: ObservableObject, Identifiable {
    let id = UUID().uuidString
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var hasNextPage = true
    @Published private var nextPageURL: URL? {
        didSet {
            if nextPageURL == nil { hasNextPage = false }
        }
    }
    @Published private var moves = Set<Move>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveCategoryViewModel")
}

extension MoveCategoryViewModel: Equatable, Hashable {
    static func == (lhs: MoveCategoryViewModel, rhs: MoveCategoryViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
extension MoveCategoryViewModel {
    @MainActor
    func loadData() async {
        logger.debug("Loading data.")
        do {
            self.moves = try await loadMoves()
            viewLoadingState = .loaded
            logger.debug("Successfuly loaded data.")
        } catch {
            logger.error("Failed to load data. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func loadNextMovesPage() async {
        logger.debug("Loading next moves page.")
        guard let nextPageURL else {
            logger.debug("No next page. nextPageURL is nil.")
            return
        }
        do {
            let movesResource = try await Resource<Move>(nextPageURL)
            self.nextPageURL = movesResource.next
            self.moves.formUnion(movesResource.items)
            
            logger.debug("Successfully loaded next moves page.")
        } catch {
            logger.error("Failed to load next moves page. \(error)")
        }
    }
    
    func sortedMoves() -> [Move] {
        self.moves.sorted()
    }
}

private extension MoveCategoryViewModel {
    @MainActor
    func loadMoves() async throws -> Set<Move> {
        logger.debug("Loading moves.")
        let movesResource = try await Resource<Move>(limit: 20)
        self.nextPageURL = movesResource.next
        logger.debug("Successfully loaded moves.")
        return movesResource.items
    }
    
    func getMoves(from resourceList: NamedAPIResourceList) async throws -> Set<Move> {
        try await withThrowingTaskGroup(of: Move.self) { group in
            for resource in resourceList.results {
                group.addTask {
                    return try await Move(resource.url)
                }
            }
            
            var moves = Set<Move>()
            for try await move in group {
                moves.insert(move)
            }
            
            return moves
        }
    }
}
