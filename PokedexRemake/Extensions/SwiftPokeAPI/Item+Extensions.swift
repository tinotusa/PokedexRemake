//
//  Item+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Item {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
}

extension Item: Equatable, Hashable {
    static public func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
