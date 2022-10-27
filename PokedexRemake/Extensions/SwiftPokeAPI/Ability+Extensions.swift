//
//  Ability+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Ability {
//    func localizedName(for language: String) -> String {
//        self.names.localizedName(language: language, default: self.name)
//    }
    
//    func localizedEffectEntry(for language: String, shortVersion: Bool) -> String {
//        let entries = self.effectEntries.localizedItems(for: language)
//        if entries.isEmpty { return "Error" }
//        if shortVersion {
//            return entries.first!.shortEffect.replacingOccurrences(of: "$effect_chance", with: "")
//        }
//        return entries.first!.effect.replacingOccurrences(of: "$effect_chance", with: "")
//    }
    
    static var example: Ability {
        Bundle.main.loadJSON("ability")
    }
}
