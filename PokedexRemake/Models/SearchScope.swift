//
//  SearchScope.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftUI

enum SearchScope: String, CaseIterable, Identifiable {
    case pokemon
    case moves
    case items
    case abilities
    case locations
    case generations
    
    var id: Self { self }
    
    var title: LocalizedStringKey {
        LocalizedStringKey(self.rawValue.capitalized)
    }
}
