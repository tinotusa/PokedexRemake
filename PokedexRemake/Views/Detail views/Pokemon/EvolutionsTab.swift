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
                ForEach(viewModel.chainLinks, id: \.self) { chainLink in
                    if let pokemon = pokemonDataStore.pokemon.first(where: {$0.name == chainLink.species.name}) {
                        pokemonImage(url: pokemon.sprites.other.officialArtwork.frontDefault)
                    }
                }
            case .error(let error):
                ErrorView(text: error.localizedDescription)
            }
        }
    }
}

private extension EvolutionsTab {
    func pokemonImage(url: URL?) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 100, height: 100)
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
