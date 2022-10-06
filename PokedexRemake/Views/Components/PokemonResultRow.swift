//
//  PokemonResultRow.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import SwiftPokeAPI

func formattedID(_ id: Int) -> String {
    String(format: "#%03d", id)
}

struct PokemonResultRow: View {
    let pokemon: Pokemon
    let pokemonSpecies: PokemonSpecies
    let generation: Generation?
    let types: [`Type`]
    let pokemonData: PokemonData
    
    init(pokemonData: PokemonData) {
        self.pokemon = pokemonData.pokemon
        self.pokemonSpecies = pokemonData.pokemonSpecies
        self.types = pokemonData.types.sorted()
        self.generation = pokemonData.generation
        self.pokemonData = pokemonData
    }
    
    @StateObject private var viewModel = PokemonResultRowViewModel()
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    
    var body: some View {
        NavigationLink(value: pokemonData) {
            HStack {
                pokemonImage
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(pokemonSpecies.localizedName(for: language))
                        Spacer()
                        if let generation {
                            Text(generation.localizedName(for: language))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        ForEach(types) { type in
                            TypeTag(type: type)
                        }
                    }
                    .bodyStyle2()
                    
                    Text(formattedID(pokemon.id))
                        .foregroundColor(.gray)
                }
            }
            .bodyStyle()
        }
    }
}

private extension PokemonResultRow {
    enum Constants {
        static let cornerRadius = 10.0
        static let imageSize = 100.0
    }
}

private extension PokemonResultRow {
    var pokemonImage: some View {
        AsyncImage(url: pokemon.sprites.other.officialArtwork.frontDefault) { image in
            image
                .resizable()
                .scaledToFit()
                .cornerRadius(Constants.cornerRadius)
        } placeholder: {
            ProgressView()
        }
        .frame(width: Constants.imageSize, height: Constants.imageSize)
    }
}

struct PokemonResultRow_Previews: PreviewProvider {
    static var previews: some View {
        PokemonResultRow(
            pokemonData: .init(
                pokemon: .example,
                pokemonSpecies: .example,
                types: [.grassExample, .poisonExample],
                generation: .example
            )
        )
    }
}
