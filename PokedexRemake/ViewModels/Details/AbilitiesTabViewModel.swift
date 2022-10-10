//
//  AbilitiesTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI

final class AbilitiesTabViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
}

extension AbilitiesTabViewModel {
    func loadData(pokemon: Pokemon) async {
        viewLoadingState = .loaded
    }
}
