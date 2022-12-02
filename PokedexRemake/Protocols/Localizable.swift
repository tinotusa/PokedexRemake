//
//  Localizable.swift
//  PokedexRemake
//
//  Created by Tino on 27/10/2022.
//

import Foundation
import SwiftPokeAPI

/// A type that can be localized.
protocol Localizable {
    var language: NamedAPIResource { get }
}
