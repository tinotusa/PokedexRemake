//
//  PokedexRemakeApp.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI
import SwiftPokeAPI

@main
struct PokedexRemakeApp: App {
    // View models
    @StateObject private var pokemonSearchResultsViewModel = PokemonSearchResultsViewModel()
    
    init() {
        do {
            try PokeAPI.shared.loadCacheFromDisk()
        } catch {
            print("Failed to load cache from disk. \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pokemonSearchResultsViewModel)
        }
    }
}
