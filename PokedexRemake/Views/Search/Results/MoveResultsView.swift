//
//  MoveResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI

struct MoveResultsView: View {
    @ObservedObject var viewModel: MoveResultsViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    viewModel.loadData()
                }
        case .loaded:
            SearchResultsView(
                items: viewModel.moves,
                emptyPlaceholderText: "Search for a move.",
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.errorMessage
            ) { move in
                MoveCard(move: move)
            } clearHistory: {
                viewModel.clearHistory()
            } moveToTop: { move in
                viewModel.moveToTop(move)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct MoveResultsView_Previews: PreviewProvider {
    static var previews: some View {
        MoveResultsView(viewModel: MoveResultsViewModel())
    }
}
