//
//  Type+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension `Type` {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
    
    static var grassExample: `Type` {
        Bundle.main.loadJSON("grassType")
    }
    
    static var poisonExample: `Type` {
        Bundle.main.loadJSON("poisonType")
    }
}

