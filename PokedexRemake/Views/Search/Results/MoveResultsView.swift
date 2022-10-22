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
            SearchResultsView(viewModel: viewModel) { move in
                MoveCard(move: move)
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
