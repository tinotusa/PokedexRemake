//
//  EvolutionsTab.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import SwiftUI

struct EvolutionsTab: View {
    let pokemonData: PokemonData
    @StateObject private var viewModel = EvolutionsTabViewModel()
    @EnvironmentObject private var pokemonDataStore: PokemonDataStore
    
    var body: some View {
        ExpandableTab(title: "Evolutions") {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
                    .task {
                        await viewModel.loadData(
                            pokemonSpecies: pokemonData.pokemonSpecies, pokemonDataStore: pokemonDataStore)
                    }
            case .loaded:
                VStack{
                    ForEach(viewModel.chainLinks, id: \.self) { chainLink in
                        if !chainLink.evolutionDetails.isEmpty { // don't show the base pokemon
                            ChainLinkView(chainLink: chainLink)
                        } else {
                            Text("No evolutions.")
                                .foregroundColor(.accentColor)
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
        EvolutionsTab(pokemonData: .init(
            pokemon: .example,
            pokemonSpecies: .example,
            types: Set([.grassExample, .poisonExample]),
            generation: .example)
        )
        .environmentObject(PokemonDataStore())
    }
}
