//
//  StatsTab.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import SwiftUI

struct StatsTab: View {
    let pokemonData: PokemonData
    
    var body: some View {
        ExpandableTab(title: "Stats") {
            VStack {
                Text("TODO!")
            }
        }
    }
}

struct StatsTab_Previews: PreviewProvider {
    static var previews: some View {
        StatsTab(pokemonData:
            .init(
                pokemon: .example,
                pokemonSpecies: .example,
                types: [.grassExample, .poisonExample],
                generation: .example
            )
        )
    }
}
