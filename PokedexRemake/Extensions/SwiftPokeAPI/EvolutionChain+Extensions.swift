//
//  EvolutionChain+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 8/10/2022.
//

import Foundation
import SwiftPokeAPI

extension EvolutionChain {
    static var example: EvolutionChain {
        Bundle.main.loadJSON("evolutionChain")
    }
}
