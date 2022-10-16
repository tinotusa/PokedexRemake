//
//  Location+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Location {
    func localizedName(languageCode: String) -> String {
        self.names.localizedName(language: languageCode, default: self.name)
    }
}


