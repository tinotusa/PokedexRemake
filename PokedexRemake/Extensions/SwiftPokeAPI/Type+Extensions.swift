//
//  Type+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension `Type`: Comparable {
    public static func < (lhs: `Type`, rhs: `Type`) -> Bool {
        lhs.id < rhs.id
    }
}

extension `Type` {
    func localizedName(for language: String) -> String {
        self.names.localizedName(language: language, default: self.name)
    }
    
    static var grassExample: `Type` {
        do {
            return try Bundle.main.loadJSON("grassType")
        } catch {
            fatalError("Failed to decode grass example. \(error)")
        }
    }
    
    static var poisonExample: `Type` {
        do {
            return try Bundle.main.loadJSON("poisonType")
        } catch {
            fatalError("Failed to decode grass example. \(error)")
        }
    }
}

