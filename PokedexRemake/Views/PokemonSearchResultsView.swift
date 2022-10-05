//
//  PokemonSearchResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI

struct PokemonSearchResultsView: View {
    @ObservedObject var viewModel: PokemonSearchResultsViewViewModel
    
    var body: some View {
        VStack {
            if viewModel.pokemon.isEmpty {
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
                // TODO: Clean up. move to functions in view model
                ForEach(viewModel.pokemon) { pokemon in
                    if let pokemonSpecies = viewModel.pokemonSpecies.first(where: { $0.id == pokemon.id }),
                       let generation = viewModel.generations.first(where: { $0.name == pokemonSpecies.generation.name }),
                       let types = viewModel.getTypes(for: pokemon)
                    {
                        PokemonResultRow(
                            pokemon: pokemon,
                            pokemonSpecies: pokemonSpecies,
                            generation: generation,
                            types: types
                        )
                    }
                }
            }
        }
    }
}

struct PokemonSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonSearchResultsView(viewModel: PokemonSearchResultsViewViewModel())
    }
}
