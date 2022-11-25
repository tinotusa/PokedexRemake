//
//  PokemonListView.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonListView: View {
    let title: String
    let description: LocalizedStringKey
    @ObservedObject var viewModel: PokemonListViewModel
    
    var body: some View {
        DetailListView(
            title: title,
            description: description
        ) {
            Group {
                switch viewModel.viewLoadingState {
                case .loading:
                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.loadPage()
                            }
                        }
                case .loaded:
                    LazyVStack {
                        ForEach(viewModel.pokemon) { pokemon in
                            PokemonResultRow(pokemon: pokemon)
                        }
                        if viewModel.hasNextPage {
                            ProgressView()
                                .task {
                                    await viewModel.loadPage()
                                }
                        }
                    }
                case .error(let error):
                    ErrorView(text: error.localizedDescription)
                }
            }
        }
    }
}

struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView(
            title: "Title here",
            description: "A list of pokemon for this particular thing.",
            viewModel: PokemonListViewModel(urls: Move.example.learnedByPokemon.urls())
        )
    }
}
