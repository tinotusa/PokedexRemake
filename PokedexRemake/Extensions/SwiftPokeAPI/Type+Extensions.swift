//
//  Type+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension `Type`: Equatable, Hashable {
    public static func == (lhs: `Type`, rhs: `Type`) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension `Type`: Comparable {
    public static func < (lhs: `Type`, rhs: `Type`) -> Bool {
        lhs.id < rhs.id
    }
}

extension `Type` {
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

