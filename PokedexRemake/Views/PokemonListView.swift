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
    let id: Int
    let description: LocalizedStringKey
    let pokemonURLs: [URL]
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
                        .task {
                            await viewModel.loadData(urls: pokemonURLs)
                        }
                case .loaded:
                    LazyVStack {
                        ForEach(viewModel.pokemon) { pokemon in
                            PokemonResultRow(pokemon: pokemon)
                        }
                        if viewModel.hasNextPage {
                            ProgressView()
                                .task {
                                    await viewModel.loadNextPage()
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
            id: 123,
            description: "A list of pokemon for this particular thing.",
            pokemonURLs: Move.example.learnedByPokemon.map { $0.url },
            viewModel: PokemonListViewModel()
        )
    }
}
