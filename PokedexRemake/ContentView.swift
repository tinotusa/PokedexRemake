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
    
    @State private var path = NavigationPath()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Pokemon.self) { pokemon in
                   PokemonDetail(pokemon: pokemon)
                }
                .navigationDestination(for: Item.self) { item in
//                    ItemDetail(item: item)
                    Text("item detail for: \(item.name)")
                }
                .navigationDestination(for: Ability.self) { ability in
                    Text("ability detail for: \(ability.name)")
                }
                .navigationDestination(for: Location.self) { location in
                    Text("Location detail for: \(location.name)")
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
    }
}
