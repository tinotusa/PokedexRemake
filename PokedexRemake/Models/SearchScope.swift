//
//  SearchScope.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftUI

/// The search scopes for the search bar.
enum SearchScope: String, CaseIterable, Identifiable {
    case pokemon
    case moves
    case items
    case abilities
    case locations
    
    var id: Self { self }
    
    /// A localized title for the search scope.
    var title: LocalizedStringKey {
        LocalizedStringKey(self.rawValue.capitalized)
    }
}
