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

extension Array where Element == VerboseEffect {
    func localizedEntry(language: String, shortVersion: Bool, effectChance: Int?) -> String {
        var effect: VerboseEffect?
        effect = self.first(where: { $0.language.name == language })
        
        if effect == nil {
            let availableLanguageCodes = self.compactMap { $0.language.name }
            let deviceLanguageCode = Bundle.preferredLocalizations(from: availableLanguageCodes, forPreferences: nil).first!
            effect = self.first(where: { $0.language.name == deviceLanguageCode })
        }
        
        if effect == nil {
            effect = self.first(where: { $0.language.name == "en" })
        }
        
        guard let effect else {
            return "Error"
        }
        
        var effectText = ""
        if shortVersion {
            effectText = effect.shortEffect
        } else {
            effectText = effect.effect
        }
        if let effectChance {
            return effectText.replacingOccurrences(of: "$effect_chance", with: "\(effectChance)")
        }
        return effectText
    }
}
