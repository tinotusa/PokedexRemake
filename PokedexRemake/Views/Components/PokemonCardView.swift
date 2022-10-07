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
    let types: Set<`Type`>
    let pokemonData: PokemonData
    @AppStorage(SettingKey.language.rawValue) var language = "en"
    
    init(pokemonData: PokemonData) {
        self.pokemon = pokemonData.pokemon
        self.pokemonSpecies = pokemonData.pokemonSpecies
        self.types = pokemonData.types
        self.pokemonData = pokemonData
    }
    
    var body: some View {
        NavigationLink(value: pokemonData) {
            VStack(alignment: .leading) {
                pokemonImage
                
                HStack {
                    Text(pokemonSpecies.localizedName(for: language))
                        .layoutPriority(1)
                    Text(formattedID(pokemon.id))
                        .foregroundColor(.gray)
                        .bodyStyle2()
                }
                .lineLimit(1)
                
                HStack {
                    ForEach(types.sorted()) { type in
                        TypeTag(type: type)
                    }
                }
            }
            .bodyStyle()
        }
    }
}

private extension PokemonCardView {
    enum Constants {
        static let imageSize = 120.0
    }
    
    var pokemonImage: some View {
        AsyncImage(url: pokemon.sprites.other.officialArtwork.frontDefault) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(width: Constants.imageSize, height: Constants.imageSize)
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView(
            pokemonData: .init(
                pokemon: .example,
                pokemonSpecies: .example,
                types: [.grassExample, .poisonExample],
                generation: .example
            )
        )
    }
}
