//
//  Move+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Move {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
    
    func localizedEffectEntry(for language: String, shortVersion: Bool, effectChance: Int? = nil) -> String {
        self.effectEntries.localizedEntry(language: language, shortVersion: shortVersion, effectChance: effectChance)
    }
    
    static var example: Move {
        Bundle.main.loadJSON("move")
    }
}

extension Move: Comparable {
    public static func < (lhs: Move, rhs: Move) -> Bool {
        lhs.id < rhs.id
    }
}
