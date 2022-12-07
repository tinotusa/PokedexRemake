//
//  FlavorText.swift
//  PokedexRemake
//
//  Created by Tino on 1/12/2022.
//

import Foundation
import SwiftPokeAPI

protocol FlavorTextProtocol {
    var flavorText: String { get }
}

extension FlavorTextProtocol {
    /// Filters the flavor text by removing any spaces and new lines.
    /// - Returns: A filtered version of the flavor text.
    func filteredFlavorText() -> String {
        self.flavorText.replacingOccurrences(of: "[\\s\\n]+", with: " ", options: .regularExpression)
    }
}

// MARK: - Conformances
extension MoveFlavorText: FlavorTextProtocol { }
extension AbilityFlavorText: FlavorTextProtocol { }
extension FlavorText: FlavorTextProtocol { }
