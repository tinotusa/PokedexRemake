//
//  ChainLinkView.swift
//  PokedexRemake
//
//  Created by Tino on 8/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct ChainLinkView: View {
    let chainLink: ChainLink
    @StateObject private var viewModel = ChainLinkViewModel()
    @EnvironmentObject private var pokemonDataStore: PokemonDataStore
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(chainLink: chainLink, pokemonDataStore: pokemonDataStore)
                }
        case .loaded:
            HStack {
                // TODO: Use the pokemon card view
                PokemonImage(url: viewModel.evolvesFromPokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
                Spacer()
                VStack {
                    Image(systemName: "chevron.right")
                    Text("one")
                    Text("one")
                    Text("one")
                    ForEach(chainLink.evolutionDetails, id: \.self) { evolutionDetail in
                        Text(evolutionDetail.trigger.name!)
                    }
                }
                Spacer()
                PokemonImage(url: viewModel.pokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension ChainLinkView {
    enum Constants {
        static let imageSize = 120.0
    }
}

struct ChainLinkView_Previews: PreviewProvider {
    static var previews: some View {
        ChainLinkView(chainLink: EvolutionChain.example.chain.evolvesTo.first!)
            .environmentObject(PokemonDataStore())
    }
}
