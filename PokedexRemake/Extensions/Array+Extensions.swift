//
//  Array+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Array where Element: Localizable {
    func localizedItems(for langaugeCode: String) -> Self {
        var localizedItems: Self?
        localizedItems = self.filter { $0.language.name == langaugeCode }
        if localizedItems == nil {
            let availableLanguages = self.compactMap { $0.language.name }
            let deviceLanguageCode = Bundle.preferredLocalizations(from: availableLanguages, forPreferences: nil).first!
            localizedItems = self.filter { $0.language.name == deviceLanguageCode }
        }
        if localizedItems == nil {
            localizedItems = self.filter { $0.language.name == "en" }
        }
        if let localizedItems {
            return localizedItems
        }
        return []
    }
}

extension Array where Element == VerboseEffect {
    func localizedEntry(language: String, shortVersion: Bool = false, effectChance: Int? = nil) -> String {
        let entries = self.localizedItems(for: language)
        if entries.isEmpty { return "Error" }
        var text = entries.first!.effect
        if shortVersion {
            text = entries.first!.shortEffect
        }
        text = text.replacingOccurrences(of: "[\\s\\f]+", with: " ", options: .regularExpression)
        if let effectChance {
            return text.replacingOccurrences(of: "$effect_chance", with: "\(effectChance)")
        }
        return text.replacingOccurrences(of: "$effect_chance", with: "")
    }
}
