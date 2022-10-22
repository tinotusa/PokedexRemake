//
//  Machine+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import Foundation
import SwiftPokeAPI

extension Machine {
    static var example: Self {
        Bundle.main.loadJSON("machine")
    }
}
