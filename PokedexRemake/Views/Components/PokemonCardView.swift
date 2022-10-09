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
    
    @AppStorage(SettingKey.language.rawValue) var language = "en"
    @StateObject private var viewModel = PokemonCardViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(from: pokemon)
                }
                .frame(width: Constants.imageSize, height: Constants.imageSize)
        case .loaded:
            NavigationLink(value: pokemon) {
                VStack(alignment: .leading) {
                    PokemonImage(url: pokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
                    
                    HStack {
                        Text(viewModel.pokemonSpecies.localizedName(for: language))
                            .layoutPriority(1)
                        Text(Globals.formattedID(pokemon.id))
                            .foregroundColor(.gray)
                            .bodyStyle2()
                    }
                    .lineLimit(1)
                    
                    HStack {
                        ForEach(Globals.sortedTypes(viewModel.types)) { type in
                            TypeTag(type: type)
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
}

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView(pokemon: .example)
    }
}
