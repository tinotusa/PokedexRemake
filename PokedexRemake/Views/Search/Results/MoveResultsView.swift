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
        VStack {
            if viewModel.moves.isEmpty {
                emptyView
            } else {
                movesList
            }
        }
    }
}

private extension MoveResultsView {
    @ViewBuilder
    func errorText() -> some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            Text("Search for a move.")
                .foregroundColor(.gray)
                .bodyStyle()
                .multilineTextAlignment(.center)
            
            errorText()
            
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
                
                errorText()
                
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
