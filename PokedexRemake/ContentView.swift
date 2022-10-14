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
    @EnvironmentObject private var moveCategoryViewModel: MoveCategoryViewModel
    
    @State private var path = NavigationPath()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Pokemon.self) { pokemon in
                   PokemonDetail(pokemon: pokemon)
                }
                .navigationDestination(for: PokemonCategoryViewModel.self) { pokemonCategoryViewModel in
                    PokemonCategoryView(viewModel: pokemonCategoryViewModel)
                }
                .navigationDestination(for: MoveCategoryViewModel.self) { moveCategoryViewModel in
                    MoveCategoryView(viewModel: moveCategoryViewModel)
                }
        }
        .onChange(of: scenePhase) { scenePhase in
            if scenePhase == .inactive {
                do {
                    try PokeAPI.shared.saveCacheToDisk()
                } catch {
                    print("Failed to save cache. \(error)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PokemonSearchResultsViewModel())
            .environmentObject(PokemonCategoryViewModel())
    }
}
