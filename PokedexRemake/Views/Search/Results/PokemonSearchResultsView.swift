//
//  PokemonSearchResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI

struct PokemonSearchResultsView: View {
    @ObservedObject var viewModel: PokemonSearchResultsViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    viewModel.loadData()
                }
        case .loaded:
            VStack {
                if viewModel.pokemon.isEmpty {
                    emptyPokemonListView
                } else {
                    pokemonListView
                }
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
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
                RecentlySearchedBar {
                    viewModel.showingClearPokemonConfirmationDialog = true
                }
                
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
                ForEach(viewModel.pokemon) { pokemon in
                    PokemonResultRow(pokemon: pokemon)
                        .simultaneousGesture(TapGesture().onEnded {
                            viewModel.moveIDToTop(pokemon.id)
                        })
                }
                .animation(nil, value: viewModel.isSearchLoading)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .confirmationDialog("Clear recently searched history.", isPresented: $viewModel.showingClearPokemonConfirmationDialog) {
            Button("Clear history", role: .destructive) {
                viewModel.clearPokemon()
            }
        } message: {
            Text("Clear recently searched history.")
        }
    }
}

struct PokemonSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonSearchResultsView(viewModel: PokemonSearchResultsViewModel())
    }
}
