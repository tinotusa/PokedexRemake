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
    let description: LocalizedStringKey
    @ObservedObject var viewModel: MovesListViewModel
    
    var body: some View {
        DetailListView(title: title, description: description) {
            Group {
                switch viewModel.viewLoadingState {
                case .loading:
                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.loadPage()
                            }
                        }
                case .loaded:
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.moves) { move in
                            MoveCard(move: move)
                            Divider()
                        }
                        if viewModel.hasNextPage {
                            ProgressView()
                                .task {
                                    await viewModel.loadPage()
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
            description: "Some description here",
            viewModel: MovesListViewModel(urls: [])
        )
    }
}
