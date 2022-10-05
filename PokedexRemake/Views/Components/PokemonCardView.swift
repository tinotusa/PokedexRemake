//
//  PokemonCardView.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonCardView: View {
    let pokemon: Pokemon
    let pokemonSpecies: PokemonSpecies
    let types: [`Type`]
    @AppStorage(SettingKey.language.rawValue) var language = "en"
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: pokemon.sprites.other.officialArtwork.frontDefault) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 120, height: 120)
            
            HStack {
                Text(pokemonSpecies.localizedName(for: language))
                    .layoutPriority(1)
                Text(formattedID(pokemon.id))
                    .foregroundColor(.gray)
                    .bodyStyle2()
            }
            .lineLimit(1)
            HStack {
                ForEach(types) { type in
                    TypeTag(type: type)
                }
            }
        }
        .bodyStyle()
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView(
            pokemon: .example,
            pokemonSpecies: .example,
            types: [.grassExample, .poisonExample]
        )
    }
}
