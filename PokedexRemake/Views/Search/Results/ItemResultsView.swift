//
//  ItemResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import SwiftUI

struct ItemResultsView: View {
    @ObservedObject var viewModel: ItemResultsViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    viewModel.loadData()
                }
        case .loaded:
            SearchResultsView(
                items: viewModel.items,
                emptyPlaceholderText: "Search for some items.",
                isLoading: viewModel.isLoading
            ) { item in
                ItemCard(item: item)
            } clearHistory: {
                viewModel.clearHistory()
            } moveToTop: { item in
                viewModel.moveToTop(item)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct ItemResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ItemResultsView(viewModel: ItemResultsViewModel())
    }
}
