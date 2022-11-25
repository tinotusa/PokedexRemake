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
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(chainLink: chainLink)
                }
        case .loaded:
            HStack {
                if let evolvesFromPokemon = viewModel.evolvesFromPokemon {
                    PokemonCardView(pokemon: evolvesFromPokemon)
                }

                Spacer()
                VStack {
                    Image(systemName: "chevron.right")
                    ForEach(chainLink.evolutionDetails, id: \.self) { evolutionDetail in
                        EvolutionDetailView(evolutionDetail: evolutionDetail)
                    }
                }
                Spacer()
                if let pokemon = viewModel.pokemon {
                    PokemonCardView(pokemon: pokemon)
                }
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadData(chainLink: chainLink)
                }
            }
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
    }
}
