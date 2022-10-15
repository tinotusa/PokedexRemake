//
//  Item+Extension.swift
//  PokedexRemake
//
//  Created by Tino on 15/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Item {
    static var example: Item {
        Bundle.main.loadJSON("item")
    }
    
    func localizedName(language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
    
    func localizedEffectEntry(language: String) -> String {
        self.effectEntries.localizedEntry(language: language, shortVersion: true, effectChance: nil)
    }
}
