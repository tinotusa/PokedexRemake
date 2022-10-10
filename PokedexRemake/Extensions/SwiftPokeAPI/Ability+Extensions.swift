//
//  Ability+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Ability {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
    
    static var example: Ability {
        Bundle.main.loadJSON("ability")
    }
}

extension Ability: Comparable {
    public static func < (lhs: Ability, rhs: Ability) -> Bool {
        lhs.id < rhs.id
    }
}
