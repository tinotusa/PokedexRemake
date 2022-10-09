//
//  EvolutionsTab.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct EvolutionsTab: View {
    let pokemon: Pokemon
    @StateObject private var viewModel = EvolutionsTabViewModel()
    
    var body: some View {
        ExpandableTab(title: "Evolutions") {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
                    .task {
                        await viewModel.loadData(pokemon: pokemon)
                    }
            case .loaded:
                VStack{
                    if viewModel.chainLinks.count == 1 {
                        Text("No evolutions.")
                            .foregroundColor(.accentColor)
                    } else {
                        ForEach(viewModel.chainLinks, id: \.self) { chainLink in
                            if !chainLink.evolutionDetails.isEmpty { // don't show the base pokemon
                                ChainLinkView(chainLink: chainLink)
                            }
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

struct EvolutionsTab_Previews: PreviewProvider {
    static var previews: some View {
        EvolutionsTab(pokemon: .example)
            .environmentObject(PokemonDataStore())
    }
}
