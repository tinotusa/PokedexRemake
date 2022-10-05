//
//  PokedexRemakeApp.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

@main
struct PokedexRemakeApp: App {
    
    // View models
    @StateObject private var pokemonSearchResultsViewModel = PokemonSearchResultsViewViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pokemonSearchResultsViewModel)
        }
    }
}
