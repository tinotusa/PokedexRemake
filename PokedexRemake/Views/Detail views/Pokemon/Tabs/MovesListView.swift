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
    let pokemon: Pokemon
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(pokemon: pokemon)
                }
        case .loaded:   
            DetailListView(title: title, id: pokemon.id, description: description) {
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
            }
            
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct MovesListView_Previews: PreviewProvider {
    static var previews: some View {
        MovesListView(
            title: "Pokemon name",
            description: "Some description here",
            viewModel: MovesListViewModel(),
            pokemon: .example
        )
    }
}
