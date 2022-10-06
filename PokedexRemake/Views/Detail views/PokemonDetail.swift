//
//  PokemonDetail.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonDetail: View {
    let pokemonData: PokemonData
    
    var body: some View {
        VStack {
            Text("TODO \(pokemonData.pokemon.name)")
        }
//        .bodyStyle()
    }
}

struct PokemonDetail_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetail(pokemonData: .init(
            pokemon: .example,
            pokemonSpecies: .example,
            types: [.grassExample, .poisonExample],
            generation: .example
            )
        )
    }
}
