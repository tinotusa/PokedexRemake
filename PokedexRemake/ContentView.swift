//
//  ContentView.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct ContentView: View {
    @EnvironmentObject private var pokemonSearchResultsViewModel: PokemonSearchResultsViewModel
    @EnvironmentObject private var pokemonCategoryViewModel: PokemonCategoryViewModel
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: PokemonData.self) { pokemonData in
                   PokemonDetail(pokemonData: pokemonData)
                }
                .navigationDestination(for: PokemonCategoryViewModel.self) { pokemonCategoryViewModel in
                    PokemonCategoryView(viewModel: pokemonCategoryViewModel)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PokemonSearchResultsViewModel())
            .environmentObject(PokemonCategoryViewModel())
            .environmentObject(PokemonDataStore())
    }
}
