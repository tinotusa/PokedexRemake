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
    
    static var example: Move {
        Bundle.main.loadJSON("move")
    }
}

extension Move: Comparable {
    public static func < (lhs: Move, rhs: Move) -> Bool {
        lhs.id < rhs.id
    }
}
