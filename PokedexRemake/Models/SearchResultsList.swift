//
//  SearchResultsList.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftUI

/// A protocol for a search results view.
protocol SearchResultsList: AnyObject {
    /// The type of results the search results list holds.
    associatedtype Element: Identifiable & Codable & Equatable
    /// The file io manager used to read and write to disk.
    var fileIOManager: FileIOManager { get }
    /// Text to be displayed when the results history is empty.
    var emptyPlaceholderText: LocalizedStringKey { get }
    /// The search results.
    var results: [Element] { get set }
    /// A Boolean value indicating whether the clear history dialog is showing.
    var showingClearHistoryDialog: Bool { get set }
    /// A boolean value indicating whether or not the search is currently loading.
    var isSearchLoading: Bool { get }
    /// An optional error message to be displayed if it is not nil.
    var errorMessage: String? { get }
    /// The filename of the save history on disk.
    static var saveFilename: String { get }

    /// Executes a search based on the given name.
    /// - parameter name: The name or id to search for.
    func search(_ name: String) async
}

extension SearchResultsList {
    /// Deletes the history on disk and clears the history in memory.
    func clearHistory() throws {
        try FileIOManager().delete(Self.saveFilename)
        results = []
    }
    
    /// Moves the search result to the top of the list.
    /// - Parameter result: The result to be moved.
    /// - Returns: Results true if the move was successful, false otherwise.
    @discardableResult
    func moveToTop(_ result: Element) -> Bool {
        guard let index = results.firstIndex(of: result) else {
            return false
        }
        results.move(fromOffsets: .init(integer: index), toOffset: 0)
        return true
    }
    
    
    /// Loads the elements from disk.
    /// - Returns: An array of Elements.
    func loadHistoryFromDisk() throws -> [Element] {
        try fileIOManager.load([Element].self, filename: Self.saveFilename)
    }
    
    /// Saves the elements search history from disk.
    func saveHistoryToDisk() throws {
        try fileIOManager.write(results, filename: Self.saveFilename)
    }
}
