//
//  AbilitiesListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import Foundation
import SwiftPokeAPI

final class AbilitiesListViewModel: ObservableObject {
    @Published private var abilities = Set<Ability>()
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
}

extension AbilitiesListViewModel {
    @MainActor
    func loadData(pokemon: Pokemon) async {
        do {
            self.abilities = try await Globals.getItems(Ability.self, urls: pokemon.abilities.map { $0.ability.url })
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    func sortedAbilities() -> [Ability] {
        self.abilities.sorted()
    }
}
