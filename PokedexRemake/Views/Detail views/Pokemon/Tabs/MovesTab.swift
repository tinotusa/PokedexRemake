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
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(pokemon: pokemon, language: language)
                }
        case .loaded:
            ScrollView {
                VStack {
                    ForEach(viewModel.sortedMoves()) { move in
                        Text(move.localizedName(for: language))
                    }
                }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
        
    }
}

struct MovesTab_Previews: PreviewProvider {
    static var previews: some View {
        MovesTab(pokemon: .example)
    }
}
