//
//  ContentView.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct ContentView: View {
    @State private var path = NavigationPath()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Pokemon.self) { pokemon in
                   PokemonDetail(pokemon: pokemon)
                }
                .navigationDestination(for: Move.self) { move in
                    MoveDetail(move: move)
                }
                .navigationDestination(for: Item.self) { item in
                    ItemDetail(item: item)
                }
                .navigationDestination(for: Ability.self) { ability in
                    AbilityDetail(ability: ability)
                }
                .navigationDestination(for: Location.self) { location in
                    Text("Location detail for: \(location.name)")
                }
                .navigationDestination(for: Generation.self) { generation in
                    Text("Generation detail for: \(generation.name)")
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
    }
}
