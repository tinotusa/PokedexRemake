//
//  Array+moveToTop.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import Foundation

extension Array where Element: Equatable {
    /// Moves the given element to index 0 if found in the array.
    /// - parameter element: The element to look for and move.
    /// - returns: True if the item was moved to index 0. False otherwise.
    mutating func moveToTop(_ element: Element) -> Bool {
        guard let index = self.firstIndex(of: element) else {
            return false
        }
        self.move(fromOffsets: .init(integer: index), toOffset: 0)
        return true
    }
}
