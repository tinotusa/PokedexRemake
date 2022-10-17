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
            if viewModel.items.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                }
                EmptySearchHistoryView(text: "Search for some items.", errorMessage: viewModel.errorMessage)
            } else {
                ScrollView {
                    LazyVStack {
                        if viewModel.isLoading {
                            ProgressView()
                        }
                        
                        SearchErrorView(text: viewModel.errorMessage)
                        
                        ForEach(viewModel.items) { item in
                            ItemCard(item: item)
                                .simultaneousGesture(
                                    TapGesture()
                                        .onEnded {
                                            viewModel.moveToTop(item)
                                        }
                                )
                        }
                    }
                }
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
