//
//  SearchResultsList.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftUI

/// A protocol for a search results view
protocol SearchResultsList {
    /// The type of results the search results list holds.
    associatedtype Element: Identifiable & Codable
    /// Text to be displayed when the results history is empty.
    var emptyPlaceholderText: LocalizedStringKey { get }
    /// The search results.
    var results: [Element] { get }
    /// A boolean value indicating whether or not the search is currently loading.
    var isSearchLoading: Bool { get }
    /// An optional error message to be displayed if it is not nil.
    var errorMessage: String? { get }
    /// The filename of the save history on disk.
    static var saveFilename: String { get }
    
    /// Clears the history from memory and disk.
    func clearHistory() -> Void
    /// Moves the given result to index 0 in the results array.
    func moveToTop(_ result: Element) -> Void
    /// Executes a search based on the given name.
    /// - parameter name: The name or id to search for.
    func search(_ name: String) async
}
