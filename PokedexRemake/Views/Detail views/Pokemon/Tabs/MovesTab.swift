//
//  MovesTab.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MovesTab: View {
    let pokemon: Pokemon
    @StateObject private var viewModel = MovesTabViewModel()
    
    
    var body: some View {
        ExpandableTab(title: "Moves") {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
                    .task {
                        await viewModel.loadData(pokemon: pokemon)
                    }
            case .loaded:
                VStack(alignment: .leading) {
                    ForEach(viewModel.sortedMoves()) { move in
                        MoveCard(move: move)
                        Divider()
                    }
                }
            case .error(let error):
                ErrorView(text: error.localizedDescription)
            }
        }
        .bodyStyle()
    }
}

struct MovesTab_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            MovesTab(pokemon: .example)
        }
    }
}
