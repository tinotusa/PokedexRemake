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
            VStack {
                if viewModel.moves.isEmpty {
                    emptyView
                } else {
                    movesList
                }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension MoveResultsView {
    var emptyView: some View {
        VStack {
            Spacer()
            Text("Search for a move.")
                .foregroundColor(.gray)
                .bodyStyle()
                .multilineTextAlignment(.center)
            
            SearchErrorView(text: viewModel.errorMessage)
            
            Spacer()
        }
    }
    
    var movesList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                RecentlySearchedBar {
                    viewModel.showingClearHistoryDialog = true
                }
                if viewModel.isLoading {
                    ProgressView()
                }
                
                SearchErrorView(text: viewModel.errorMessage)
                
                ForEach(viewModel.moves) { move in
                    MoveCard(move: move)
                }
            }
        }
        .confirmationDialog("Clear history", isPresented: $viewModel.showingClearHistoryDialog) {
            Button("Clear history", role: .destructive) {
                viewModel.clearHistory()
            }
        } message: {
            Text("Clear history?")
        }
    }
}

struct MoveResultsView_Previews: PreviewProvider {
    static var previews: some View {
        MoveResultsView(viewModel: MoveResultsViewModel())
    }
}
