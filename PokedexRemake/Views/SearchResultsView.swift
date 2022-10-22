//
//  SearchResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import SwiftUI
import SwiftPokeAPI


struct SearchResultsView<T: SearchResultsList & ObservableObject, Content: View>: View {
    @ObservedObject var viewModel: T
    var content: (T.Element) -> Content
    
    @State private var showingClearHistoryDialog = false
    
    var body: some View {
        if viewModel.results.isEmpty {
            EmptySearchHistoryView(
                text: viewModel.emptyPlaceholderText,
                isLoading: viewModel.isSearchLoading,
                errorMessage: viewModel.errorMessage
            )
        } else {
            ScrollView {
                LazyVStack {
                    RecentlySearchedBar {
                        showingClearHistoryDialog = true
                    }
                    
                    if viewModel.isSearchLoading {
                        ProgressView()
                    }
                    
                    SearchErrorView(text: viewModel.errorMessage)
                    
                    ForEach(viewModel.results) { item in
                        content(item)
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        viewModel.moveToTop(item)
                                    }
                            )
                    }
                }
            }
            .confirmationDialog(
                "Clear history",
                isPresented: $showingClearHistoryDialog
            ) {
                Button("Clear history", role: .destructive) {
                    viewModel.clearHistory()
                }
            } message: {
                Text("Clear recently searched history")
            }
        }
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(viewModel: PokemonResultsViewModel()) { pokemon in
            PokemonResultRow(pokemon: pokemon)
        }
    }
}
