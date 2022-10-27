//
//  Generation+Extension.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Generation {
//    func localizedName(for language: String) -> String {
//        self.names.localizedName(language: language, default: self.name)
//    }
    
    static var example: Generation {
        Bundle.main.loadJSON("generation")
    }
}
