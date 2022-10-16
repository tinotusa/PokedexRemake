//
//  MoveResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class MoveResultsViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var moves = [Move]() {
        didSet {
            saveToDisk()
        }
    }
    @Published var showingClearHistoryDialog = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    static let saveFilename = "moveResults"
    private let fileIOManager = FileIOManager()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveResultsViewModel")
}

extension MoveResultsViewModel {
    @MainActor
    func loadData() {
        do {
            self.moves = try loadFromDisk()
            viewLoadingState = .loaded
        } catch CocoaError.fileReadNoSuchFile {
            // Do nothing file will be created on save.
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    @MainActor
    func search(_ name: String) async {
        logger.debug("Searching for move with name: \(name).")
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
                logger.debug("Move already in history. Moving it to top.")
                return
            }
            self.moves.insert(move, at: 0)
            logger.debug("Successfully found move.")
        } catch PokeAPIError.invalidServerResponse(let code) where code == 404 {
            if let id = Int(name) {
                errorMessage = "Couldn't find move with id: \(id)."
            } else {
                errorMessage = "Couldn't find move with name: \(name)."
            }
            logger.debug("Failed to find move. Due to server 404 error.")
        } catch {
            logger.error("Failed to find move with name: \(name). \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func clearHistory() {
        self.moves = []
        logger.debug("Cleared move search history.")
    }
}

private extension MoveResultsViewModel {
    func shiftToTop(_ move: Move) {
        guard let index = self.moves.firstIndex(of: move) else { return }
        self.moves.move(fromOffsets: .init(integer: index), toOffset: 0)
    }
    
    func loadFromDisk() throws -> [Move] {
        try fileIOManager.load([Move].self, documentName: Self.saveFilename)
    }
    
    func saveToDisk() {
        logger.debug("Saving data to disk.")
        do {
            try fileIOManager.write(self.moves, documentName: Self.saveFilename)
            logger.debug("Successfully saved data to disk.")
        } catch {
            logger.error("Failed to save to disk. \(error)")
        }
    }
}
