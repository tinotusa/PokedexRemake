//
//  MoveResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os
// TODO: loading
// TODO: saving
final class MoveResultsViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var moves = [Move]()
    @Published var showingClearHistoryDialog = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveResultsViewModel")
}

extension MoveResultsViewModel {
    @MainActor
    func search(_ name: String) async {
        if name.isEmpty {
            logger.debug("Search text is empty.")
            return
        }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            let move = try await Move(name)
            if self.moves.contains(move) {
                shiftToTop(move)
                return
            }
            self.moves.insert(move, at: 0)
        } catch PokeAPIError.invalidServerResponse(let code) where code == 404 {
            if let id = Int(name) {
                errorMessage = "Couldn't find move with id: \(id)."
            } else {
                errorMessage = "Couldn't find move with name: \(name)."
            }
        } catch {
            logger.error("Failed to find move with name: \(name). \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func clearHistory() {
        self.moves = []
    }
}

private extension MoveResultsViewModel {
    func shiftToTop(_ move: Move) {
        guard let index = self.moves.firstIndex(of: move) else { return }
        self.moves.move(fromOffsets: .init(integer: index), toOffset: 0)
    }
}
