//
//  PokemonDetail.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonDetail: View {
    let pokemon: Pokemon
    let pokemonSpecies: PokemonSpecies
    let types: [`Type`]
    
    init(pokemonData: PokemonData) {
        self.pokemon = pokemonData.pokemon
        self.pokemonSpecies = pokemonData.pokemonSpecies
        self.types = pokemonData.types
    }
    
    var body: some View {
        VStack {
            Text("TODO \(pokemon.name)")
        }
//        .bodyStyle()
    }
}

struct PokemonDetail_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetail(pokemonData: .init(
            pokemon: .example,
            pokemonSpecies: .example,
            types: [.grassExample, .poisonExample]
            )
        )
    }
}
