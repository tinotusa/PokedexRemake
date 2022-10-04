//
//  PokemonResultRow.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import SwiftPokeAPI

extension Pokemon {
    static var example: Pokemon {
        let url = Bundle.main.url(forResource: "pokemon", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! decoder.decode(Pokemon.self, from: data)
    }
}

extension PokemonType: Identifiable {
    public var id: URL { self.type.url }
}

struct PokemonResultRow: View {
    let pokemon: Pokemon
    
    var body: some View {
        HStack {
            AsyncImage(url: pokemon.sprites.other.officialArtwork.frontDefault) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(pokemon.name)
                    Spacer()
                    Text("some generation")
                        .foregroundColor(.gray)
                }
                HStack {
                    ForEach(pokemon.types) { pokemonType in
                        Text(pokemonType.type.name!)
                    }
                }
                .bodyStyle2()
                Text(String(format: "#%03d", pokemon.id))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct PokemonResultRow_Previews: PreviewProvider {
    static var previews: some View {
        PokemonResultRow(pokemon: .example)
    }
}
