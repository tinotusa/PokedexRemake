//
//  LocationArea+Extensions.swift
//  PokedexRemake
//
//  Created by Tino on 1/11/2022.
//

import Foundation
import SwiftPokeAPI

extension LocationArea {
    func filteredName(languageCode: String) -> String {
        let filteredName = self.localizedName(languageCode: languageCode)
        if filteredName.isEmpty {
            return self.name
        }
        return filteredName
    }
}
