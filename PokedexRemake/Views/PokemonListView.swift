//
//  PokemonListView.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import SwiftUI

struct PokemonListView: View {
    let pokemoURLs: [URL]
    @ObservedObject var viewModel: PokemonListViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(urls: pokemoURLs)
                }
        case .loaded:
            ScrollView {
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
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView(pokemoURLs: [], viewModel: PokemonListViewModel())
    }
}
