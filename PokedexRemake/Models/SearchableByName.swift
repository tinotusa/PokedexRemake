//
//  SearchableByName.swift
//  PokedexRemake
//
//  Created by Tino on 18/11/2022.
//

import Foundation
import SwiftPokeAPI

protocol SearchableByName {
    init(_ name: String) async throws
}

extension Pokemon: SearchableByName { }
extension Move: SearchableByName { }
extension Location: SearchableByName { }
extension Item: SearchableByName { }
extension Ability: SearchableByName { }
