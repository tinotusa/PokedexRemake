//
//  SearchResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct SearchResultsView<T: Identifiable, Content: View>: View {
    let items: [T]
    var emptyPlaceholderText: LocalizedStringKey
    var isLoading: Bool
    var errorMessage: String?
    var content: (T) -> Content
    var clearHistory: () -> Void
    
    @State private var showingClearHistoryDialog = false
    
    var body: some View {
        if items.isEmpty {
            EmptySearchHistoryView(
                text: emptyPlaceholderText,
                isLoading: isLoading,
                errorMessage: errorMessage
            )
        } else {
            ScrollView {
                LazyVStack {
                    RecentlySearchedBar {
                        showingClearHistoryDialog = true
                    }
                    
                    if isLoading {
                        ProgressView()
                    }
                    
                    SearchErrorView(text: errorMessage)
                    
                    ForEach(items) { item in
                        content(item)
                    }
                }
            }
            .confirmationDialog(
                "Clear history",
                isPresented: $showingClearHistoryDialog
            ) {
                Button("Clear history", role: .destructive) {
                    clearHistory()
                }
            } message: {
                Text("Clear recently searched history")
            }
        }
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(
            items: [Pokemon.example],
            emptyPlaceholderText: "Search for a pokemon",
            isLoading: false
        ) { pokemon in
            PokemonResultRow(pokemon: pokemon)
        } clearHistory: {
            // nothing
        }
    }
}
