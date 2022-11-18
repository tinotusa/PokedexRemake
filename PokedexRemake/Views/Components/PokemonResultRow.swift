//
//  PokemonResultRow.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonResultRow: View {
    let pokemon: Pokemon
    
    @StateObject private var viewModel = PokemonResultRowViewModel()
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPlaceholder
                .task {
                    await viewModel.loadData(pokemon: pokemon)
                }
        case .loaded:
            NavigationLink(value: pokemon) {
                HStack {
                    PokemonImage(url: pokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(viewModel.pokemonSpecies.localizedName(languageCode: language))
                            Spacer()
                            Text(viewModel.generation.localizedName(languageCode: language))
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            ForEach(Globals.sortedTypes(viewModel.types)) { type in
                                TypeTag(type: type)
                            }
                        }
                        .bodyStyle2()
                        
                        Text(Globals.formattedID(pokemon.id))
                            .foregroundColor(.gray)
                    }
                }
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
        
    }
}

private extension PokemonResultRow {
    enum Constants {
        static let cornerRadius = 10.0
        static let imageSize = 100.0
    }
    
    var loadingPlaceholder: some View {
        HStack {
            Image("bulbasaur")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.imageSize, height: Constants.imageSize)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Species name")
                    Spacer()
                    Text("Genreation name")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    ForEach(0 ..< 2) { index in
                        Text("type \(index)")
                    }
                }
                .bodyStyle2()
                
                Text("#999")
                    .foregroundColor(.gray)
            }
        }
        .bodyStyle()
        .redacted(reason: .placeholder)
    }
}

struct PokemonResultRow_Previews: PreviewProvider {
    static var previews: some View {
        PokemonResultRow(pokemon: .example)
    }
}
