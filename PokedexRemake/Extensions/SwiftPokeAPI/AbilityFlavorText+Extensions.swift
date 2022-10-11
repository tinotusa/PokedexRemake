//
//  AbilityFlavorText+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 11/10/2022.
//

import Foundation
import SwiftPokeAPI

extension AbilityFlavorText {
    func filteredFlavorText() -> String {
        self.flavorText.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression)
    }
}
