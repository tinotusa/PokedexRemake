//
//  Sequence+urls.swift
//  PokedexRemake
//
//  Created by Tino on 20/11/2022.
//

import Foundation
import SwiftPokeAPI

extension Sequence where Element == NamedAPIResource {
    /// Returns the URLs from the array.
    /// - Returns: An array of URLs
    func urls() -> [URL] {
        self.map { $0.url }
    }
}
