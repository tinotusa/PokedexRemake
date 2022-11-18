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
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 150, maximum: 200))]
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .onAppear {
                    Task {
                        await viewModel.loadData()
                    }
                }
        case .loaded:
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.pokemon.sorted()) { pokemon in
                        PokemonCardView(pokemon: pokemon)
                    }
                    if viewModel.hasNextPage {
                        ProgressView()
                            .task {
                                await viewModel.loadNextPage()
                            }
                    }
                }
            }
            .navigationTitle("Pokemon")
            .background(Color.background)
        case .error(let error):
            Text(error.localizedDescription)
        }
    }
}

struct PokemonCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PokemonCategoryView(viewModel: PokemonCategoryViewModel())
        }
    }
}
