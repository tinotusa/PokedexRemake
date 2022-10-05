//
//  PokemonType+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftPokeAPI

extension PokemonType: Identifiable {
    public var id: URL { self.type.url }
}
