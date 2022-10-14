//
//  MoveCategoryView.swift
//  PokedexRemake
//
//  Created by Tino on 14/10/2022.
//

import SwiftUI

struct MoveCategoryView: View {
    @ObservedObject var viewModel: MoveCategoryViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData()
                }
        case .loaded:
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.sortedMoves()) { move in
                        MoveCard(move: move)
                        Divider()
                    }
                    if viewModel.hasNextPage {
                        ProgressView()
                            .task {
                                await viewModel.loadNextMovesPage()
                            }
                    }
                }
                .padding()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
        
    }
}

struct MoveCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        MoveCategoryView(viewModel:  MoveCategoryViewModel())
    }
}
