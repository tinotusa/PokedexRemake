//
//  Array+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Array where Element == Name {
    func localizedName(language: String, default defaultValue: String) -> String {
        let name = self.first { name in
            name.language.name == language
        }
        if let name {
            return name.name
        }
        return defaultValue
    }
}

extension Array where Element == FlavorText {
    func localizedEntries(language: String) -> [FlavorText] {
        let flavorTexts = self.filter { flavorText in
            flavorText.language.name == language
        }
        return flavorTexts
    }
}
