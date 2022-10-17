//
//  PokemonResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI

struct PokemonResultsView: View {
    @ObservedObject var viewModel: PokemonResultsViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    viewModel.loadData()
                }
        case .loaded:
            SearchResultsView(
                items: viewModel.pokemon,
                emptyPlaceholderText: "Search for a pokemon",
                isLoading: viewModel.isSearchLoading
            ) { pokemon in
                PokemonResultRow(pokemon: pokemon)
            } clearHistory: {
                viewModel.clearPokemon()
            } moveToTop: { pokemon in
                viewModel.moveIDToTop(pokemon.id)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct PokemonResultsView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonResultsView(viewModel: PokemonResultsViewModel())
    }
}
