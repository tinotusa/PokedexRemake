//
//  PokemonSearchResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI

struct PokemonSearchResultsView: View {
    @ObservedObject var viewModel: PokemonSearchResultsViewModel
    @EnvironmentObject private var pokemonDataStore: PokemonDataStore
    
    var body: some View {
        VStack {
            if pokemonDataStore.pokemon.isEmpty {
                emptyPokemonListView
            } else {
                pokemonListView
            }
        }
        .bodyStyle()
    }
}

private extension PokemonSearchResultsView {
    var emptyPokemonListView: some View {
        VStack {
            if viewModel.isSearchLoading {
                ProgressView()
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
            }
            Spacer()
            Text("No recent searches. Search for a pokemon.")
            
            if let errorText = viewModel.errorText {
                Text(errorText)
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .multilineTextAlignment(.center)
    }
    
    var pokemonListView: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                // TODO: make into view (other search views will have the same bar)
                HStack {
                    Text("Recently searched")
                        .foregroundColor(.gray)
                    Spacer()
                    Button {
                        viewModel.clearRecentlySearched()
                    } label: {
                        Text("Clear")
                            .foregroundColor(.accentColor)
                    }
                }
                .bodyStyle2()
                
                // TODO: make into view 
                if let errorText = viewModel.errorText {
                    Text(errorText)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.red)
                }
                
                Divider()
                if viewModel.isSearchLoading {
                    ProgressView()
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            )
                        )
                }
                ForEach(pokemonDataStore.pokemon.sorted()) { pokemon in
                    if let pokemonData = try? pokemonDataStore.pokemonData(for: pokemon),
                       let generation = pokemonDataStore.generations.first(where: {$0.name == pokemonData.pokemonSpecies.generation.name}) {
                        PokemonResultRow(pokemonData: pokemonData, generation: generation)
                    }
                }
            }
        }
    }
}

struct PokemonSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonSearchResultsView(viewModel: PokemonSearchResultsViewModel())
            .environmentObject(PokemonDataStore())
    }
}
