//
//  Version+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Version {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
}

extension Version: Comparable {
    public static func < (lhs: Version, rhs: Version) -> Bool {
        lhs.id < rhs.id
    }
}
