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
        if viewModel.pokemon.isEmpty {
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
        } else {
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack {
                        Text("Recently searched")
                            .foregroundColor(.gray)
                        Spacer()
                        Button {
                            viewModel.clearRecentlySearched()
                        } label: {
                            Text("Clear")
                                .foregroundColor(.red)
                        }
                    }
                    .bodyStyle2()
                    
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
                    ForEach(viewModel.pokemon) { pokemon in
                        PokemonResultRow(pokemon: pokemon)
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
