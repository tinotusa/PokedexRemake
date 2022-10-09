//
//  PokemonCategoryView.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonCategoryView: View {
    @ObservedObject var viewModel: PokemonCategoryViewModel
    @EnvironmentObject private var pokemonDataStore: PokemonDataStore
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 200))]
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(pokemonDataStore: pokemonDataStore)
                }
        case .loaded:
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(pokemonDataStore.pokemon.sorted()) { pokemon in
                        PokemonCardView(pokemon: pokemon)
                    }
                    if viewModel.hasNextPage {
                        ProgressView()
                            .task {
                                await viewModel.loadNextPage(pokemonDataStore: pokemonDataStore)
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
        PokemonCategoryView(viewModel: PokemonCategoryViewModel())
            .environmentObject(PokemonDataStore())
    }
}
