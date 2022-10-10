//
//  Ability+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Ability: Comparable {
    public static func < (lhs: Ability, rhs: Ability) -> Bool {
        lhs.id < rhs.id
    }
}
