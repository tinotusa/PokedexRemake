//
//  SearchResultsListView.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct SearchResultsListView<T: Identifiable & Codable & Equatable & SearchableByName, Content: View>: View {
    @ObservedObject var viewModel: SearchResultsListViewModel<T>
    /// The search result row content.
    var content: (T) -> Content
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    viewModel.loadData()
                }
        case .loaded:
            SearchResultsView(viewModel: viewModel) { pokemon in
                content(pokemon)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct SearchResultsListView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsListView(viewModel: SearchResultsListViewModel<Pokemon>(saveFilename: "testing")) { pokemon in
            PokemonResultRow(pokemon: pokemon)
        }
    }
}
