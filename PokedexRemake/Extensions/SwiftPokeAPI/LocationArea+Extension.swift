//
//  LocationArea+Extension.swift
//  PokedexRemake
//
//  Created by Tino on 31/10/2022.
//

import Foundation
import SwiftPokeAPI

extension LocationArea {
    static var example: LocationArea {
        Bundle.main.loadJSON("locationArea")
    }
}
