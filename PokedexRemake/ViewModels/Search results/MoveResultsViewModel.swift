//
//  MoveResultsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import SwiftUI
import os

protocol SearchableByName {
    init(_ name: String) async throws
}

//final class SearchResultsViewModel<T: Codable & SearchableByName>: ObservableObject, SearchResultsList {
//    /// The loading state of the view.
//    @Published private(set) var viewLoadingState = ViewLoadingState.loading
//    @Published var results = [T]() {
//        didSet {
//            do {
//                try saveHistoryToDisk()
//            } catch {
//                logger.error("Failed to save history to disk. \(error)")
//            }
//        }
//    }
//    @Published var showingClearHistoryDialog = false
//    @Published private(set) var isSearchLoading = false
//    @Published private(set) var errorMessage: String?
//    private(set) var emptyPlaceholderText: LocalizedStringKey = "Search for a move."
//    
//    let saveFilename: String = UUID().uuidString
//    let fileIOManager = FileIOManager()
//    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "SearchResultsViewModel")
//}
//
//extension SearchResultsViewModel {
//    /// Loads MoveResults from disk.
//    @MainActor
//    func loadData() {
//        do {
//            self.results = try loadHistoryFromDisk()
//            viewLoadingState = .loaded
//        } catch CocoaError.fileReadNoSuchFile {
//            // Do nothing file will be created on save.
//            viewLoadingState = .loaded
//        } catch {
//            viewLoadingState = .error(error: error)
//        }
//    }
//    
//    @MainActor
//    func search(_ name: String) async {
//        logger.debug("Searching for move with name: \(name).")
//        if name.isEmpty {
//            logger.debug("Search text is empty.")
//            return
//        }
//        errorMessage = nil
//        isSearchLoading = true
//        defer { isSearchLoading = false }
//        
//        do {
//            let move = try await T(name)
//            if self.results.contains(move) {
//                moveToTop(move)
//                logger.debug("Move already in history. Moving it to top.")
//                return
//            }
//            self.results.insert(move, at: 0)
//            logger.debug("Successfully found move.")
//        } catch PokeAPIError.invalidServerResponse(let code) where code == 404 {
//            if let id = Int(name) {
//                errorMessage = "Couldn't find move with id: \(id)."
//            } else {
//                errorMessage = "Couldn't find move with name: \(name)."
//            }
//            logger.debug("Failed to find move. Due to server 404 error.")
//        } catch {
//            logger.error("Failed to find move with name: \(name). \(error)")
//            errorMessage = error.localizedDescription
//        }
//    }
//}
//
//


// ********************


/// View model for MoveResults.
final class MoveResultsViewModel: ObservableObject, SearchResultsList {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published var results = [Move]() {
        didSet {
            do {
                try saveHistoryToDisk()
            } catch {
                logger.error("Failed to save history to disk. \(error)")
            }
        }
    }
    @Published var showingClearHistoryDialog = false
    @Published private(set) var isSearchLoading = false
    @Published private(set) var errorMessage: String?
    private(set) var emptyPlaceholderText: LocalizedStringKey = "Search for a move."
    
    let saveFilename = "moveResults"
    let fileIOManager = FileIOManager()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveResultsViewModel")
}

extension MoveResultsViewModel {
    /// Loads MoveResults from disk.
    @MainActor
    func loadData() {
        do {
            self.results = try loadHistoryFromDisk()
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
        isSearchLoading = true
        defer { isSearchLoading = false }
        
        do {
            let move = try await Move(name)
            if self.results.contains(move) {
                moveToTop(move)
                logger.debug("Move already in history. Moving it to top.")
                return
            }
            self.results.insert(move, at: 0)
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
}
