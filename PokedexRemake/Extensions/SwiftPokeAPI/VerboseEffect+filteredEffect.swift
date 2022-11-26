//
//  VerboseEffect+filteredEffect.swift
//  PokedexRemake
//
//  Created by Tino on 26/11/2022.
//

import Foundation
import SwiftPokeAPI

extension VerboseEffect {
    /// The effect versions (short or full).
    enum EffectVersion {
        case short, full
    }
    /// Replaces $effect_chance with a value if one is given.
    /// - Parameters:
    ///   - short: Whether or not to return the short effect.
    ///   - effectChance: The value of the effect.
    /// - Returns: A filtered string if the effectChance was not nil.
    func filteredEffect(_ effectVersion: EffectVersion, effectChance: Int? = nil) -> String {
        var text = effect
        if effectVersion == .short {
            text = shortEffect
        }
        if let effectChance {
            text = text.replacing("$effect_chance", with: "\(effectChance)")
        }
        return text
    }
}
