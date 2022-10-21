//
//  EffectEntriesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 21/10/2022.
//

import Foundation

final class EffectEntriesListViewModel: ObservableObject, Identifiable {
    let id = UUID().uuidString
}

extension EffectEntriesListViewModel: Hashable {
    static func == (lhs: EffectEntriesListViewModel, rhs: EffectEntriesListViewModel) -> Bool {
        lhs .id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
