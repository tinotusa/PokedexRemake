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
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    
    private let pokemonSpecies: PokemonSpecies
    private let pokemon: Pokemon
    
    init(pokemonData: PokemonData) {
        self.pokemonData = pokemonData
        self.pokemon = pokemonData.pokemon
        self.pokemonSpecies = pokemonData.pokemonSpecies
    }
    
    var body: some View {
        ScrollView {
            VStack {
                PokemonImage(url: pokemonData.pokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
                nameAndID
             
                AboutTab(pokemonData: pokemonData)
                StatsTab(pokemonData: pokemonData)
                EvolutionsTab(pokemonData: pokemonData)
                movesTab
                abilitiesTab
            }
            .padding()
        }
        .bodyStyle()
    }
}

private extension PokemonDetail {
    enum Constants {
        static let imageSize = 300.0
    }
    
    var nameAndID: some View {
        HStack {
            Text(pokemonSpecies.localizedName(for: language))
            Spacer()
            Text(formattedID(pokemon.id))
                .foregroundColor(.gray)
                .fontWeight(.light)
        }
        .titleStyle()
    }
    
    var movesTab: some View {
        ExpandableTab(title: "Moves") {
            Text("TODO!")
        }
    }
    
    var abilitiesTab: some View {
        ExpandableTab(title: "Abilities") {
            Text("TODO!")
        }
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
        .environmentObject(PokemonDataStore())
    }
}
