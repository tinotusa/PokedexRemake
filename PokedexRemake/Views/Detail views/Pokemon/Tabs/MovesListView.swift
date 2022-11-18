//
//  MovesListView.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MovesListView: View {
    let title: String
    let id: Int
    let description: LocalizedStringKey
    let moveURLS: [URL]
    @ObservedObject var viewModel: MovesListViewModel
    
    var body: some View {
        DetailListView(title: title, description: description) {
            Group {
                switch viewModel.viewLoadingState {
                case .loading:
                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.loadData(moveURLS: moveURLS)
                            }
                        }
                case .loaded:
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.sortedMoves()) { move in
                            MoveCard(move: move)
                            Divider()
                        }
                        if viewModel.hasNextPage {
                            ProgressView()
                                .task {
                                    await viewModel.getNextPage()
                                }
                        }
                    }
                    .bodyStyle()
                    
                case .error(let error):
                    ErrorView(text: error.localizedDescription)
                }
            }
        }
    }
}

struct MovesListView_Previews: PreviewProvider {
    static var previews: some View {
        MovesListView(
            title: "Pokemon name",
            id: 123,
            description: "Some description here",
            moveURLS: [],
            viewModel: MovesListViewModel()
        )
    }
}
