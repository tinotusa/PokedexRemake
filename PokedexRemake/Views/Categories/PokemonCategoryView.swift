//
//  PokemonCategoryView.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonCategoryView: View {
    @ObservedObject var viewModel: PokemonCategoryViewViewModel
    private let columns: [GridItem] = [.init(.adaptive(minimum: 200))]
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData()
                }
        case .loaded:
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.pokemon) { pokemon in
                        if let pokemonSpecies = viewModel.pokemonSpecies(for: pokemon),
                           let types = viewModel.types(for: pokemon) {
                            PokemonCardView(
                                pokemon: pokemon,
                                pokemonSpecies: pokemonSpecies,
                                types: types
                            )
                        }
                    }
                    if viewModel.hasNextPage {
                        ProgressView()
                            .task {
                                await viewModel.loadNextPage()
                            }
                    }
                }
            }
        case .error(let error):
            Text(error.localizedDescription)
        }
    }
}

struct PokemonCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCategoryView(viewModel: PokemonCategoryViewViewModel())
    }
}
