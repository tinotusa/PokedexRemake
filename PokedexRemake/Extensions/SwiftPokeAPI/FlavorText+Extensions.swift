//
//  FlavorText+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import Foundation
import SwiftPokeAPI

extension FlavorText {
    func filteredText() -> String {
        self.flavorText.replacingOccurrences(of: "[\\n\\f]+", with: " ", options: .regularExpression)
    }
}

extension FlavorText: Identifiable {
    public var id: String {
        if let versionName = self.version?.name {
            return self.flavorText + versionName
        }
        return self.flavorText
    }
}
