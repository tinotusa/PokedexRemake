//
//  PokedexRemakeApp.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

@main
struct PokedexRemakeApp: App {
    @StateObject private var pokemonDataStore = PokemonDataStore()
    // View models
    @StateObject private var pokemonSearchResultsViewModel = PokemonSearchResultsViewModel()
    // category view models
    @StateObject private var pokemonCategoryViewModel = PokemonCategoryViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pokemonSearchResultsViewModel)
                .environmentObject(pokemonCategoryViewModel)
                .environmentObject(pokemonDataStore)
        }
    }
}
