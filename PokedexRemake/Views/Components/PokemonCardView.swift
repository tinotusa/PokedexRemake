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
    
    @AppStorage(SettingsKey.language) var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel = PokemonCardViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPreview
                .onAppear {
                    Task {
                        await viewModel.loadData(from: pokemon)
                    }
                }
                .frame(width: Constants.imageSize, height: Constants.imageSize)
        case .loaded:
            NavigationLink(value: pokemon) {
                VStack(alignment: .leading) {
                    PokemonImage(url: pokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
                    
                    HStack {
                        Text(viewModel.pokemonSpecies.localizedName(languageCode: language))
                            .layoutPriority(1)
                        Text(Globals.formattedID(pokemon.id))
                            .foregroundColor(.gray)
                            .bodyStyle2()
                    }
                    .lineLimit(1)
                    ViewThatFits(in: .horizontal) {
                        HStack {
                            ForEach(Globals.sortedTypes(viewModel.types)) { type in
                                TypeTag(type: type)
                            }
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(Globals.sortedTypes(viewModel.types)) { type in
                                TypeTag(type: type)
                            }
                        }
                    }
                }
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension PokemonCardView {
    enum Constants {
        static let imageSize = 120.0
    }
    
    var loadingPreview: some View {
        VStack(alignment: .leading) {
            Image("bulbasaur")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.imageSize, height: Constants.imageSize)

            HStack {
                Text("Some pokemon")
                    .layoutPriority(1)
                Text("#999")
                    .foregroundColor(.gray)
                    .bodyStyle2()
            }
            .lineLimit(1)
            
            HStack {
                ForEach(0 ..< 2) { index in
                    Text("type\(index)")
                }
            }
        }
        .redacted(reason: .placeholder)
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView(pokemon: .example)
    }
}
