//
//  Stat+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Stat {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
}
