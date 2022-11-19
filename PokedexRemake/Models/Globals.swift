//
//  Globals.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI
import os
import SwiftUI

/// A struct that holds functions that are used throughout the app.
struct Globals {
    /// Fetches items from the given URLs.
    ///
    /// The offset skips the first n elements and fetches moves from offset to offset + limit
    ///
    ///     let urls: [URL] = [...]
    ///     let offset = 10
    ///     let moves = getItems(Move.self, urls: urls, offset: offset) // starts from urls[offset..< offset + limit]
    ///
    /// - Parameters:
    ///   - urls: The URLs for the moves.
    ///   - limit: The number of moves to fetch.
    ///   - offset: The offset to start from within the URLs.
    /// - Returns: A set of items.
    static func getItems<T: Codable & SearchableByURL>(_ type: T.Type, urls: [URL], limit: Int = 0, offset: Int = 0) async throws -> Set<T> {
        var limit = limit
        var offset = offset
        if limit == 0 {
            limit = urls.count
            offset = 0
        }
        return try await withThrowingTaskGroup(of: T.self) { group in
            for (i, url) in urls.enumerated() where i >= offset && i < offset + limit {
                group.addTask {
                    return try await T(url)
                }
            }
            
            var items = Set<T>()
            for try await item in group {
                items.insert(item)
            }
            return items
        }
    }
    
    /// Formats the given ID.
    ///
    ///     let formattedID = Globals.formattedID(1)
    ///     print(formattedID) // "#001"
    ///
    /// - Parameter id: The ID to format
    /// - Returns: The formatted ID.
    static func formattedID(_ id: Int) -> String {
        String(format: "#%03d", id)
    }
    
    /// Returns a sorted array of Types.
    /// - Parameter types: The set of types to sort.
    /// - Returns: A sorted array of Types.
    static func sortedTypes(_ types: Set<`Type`>) -> [`Type`] {
        types.sorted()
    }
}
