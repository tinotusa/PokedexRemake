//
//  EvolutionsTab.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import SwiftUI

struct EvolutionsTab: View {
    let pokemonData: PokemonData
    
    var body: some View {
        ExpandableTab(title: "Evolutions") {
            VStack {
                Text("todo!")
            }
        }
    }
}

struct EvolutionsTab_Previews: PreviewProvider {
    static var previews: some View {
        EvolutionsTab(pokemonData: .init(
            pokemon: .example,
            pokemonSpecies: .example,
            types: Set([.grassExample, .poisonExample]),
            generation: .example)
        )
    }
}
