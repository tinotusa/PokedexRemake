//
//  PokemonDetail.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI
import SwiftPokeAPI
import os

final class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var pokemonSpecies: PokemonSpecies!
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private var logger = Logger(subsystem: "com.tinotusa.Pokedex", category: "PokemonDetailViewModel")
    
    @MainActor
    func loadData(from pokemon: Pokemon) async {
        let id = pokemon.species.url.lastPathComponent
        do {
            self.pokemonSpecies = try await PokemonSpecies(id)
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to get pokemon species from pokemon with id: \(pokemon.id)")
            viewLoadingState = .error(error: error)
        }
    }
}

struct PokemonDetail: View {
    let pokemon: Pokemon
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    @StateObject private var viewModel = PokemonDetailViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(from: pokemon)
                }
        case .loaded:
            ScrollView {
                VStack {
                    PokemonImage(url: pokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
                    nameAndID
                 
                    AboutTab(pokemon: pokemon)
                    StatsTab(pokemon: pokemon)
                    EvolutionsTab(pokemon: pokemon)
                    movesTab
                    abilitiesTab
                }
                .padding()
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension PokemonDetail {
    enum Constants {
        static let imageSize = 300.0
    }
    
    var nameAndID: some View {
        HStack {
            Text(viewModel.pokemonSpecies.localizedName(for: language))
            Spacer()
            Text(Globals.formattedID(pokemon.id))
                .foregroundColor(.gray)
                .fontWeight(.light)
        }
        .titleStyle()
    }
    
    var movesTab: some View {
        ExpandableTab(title: "Moves") {
            Text("TODO!")
        }
    }
    
    var abilitiesTab: some View {
        ExpandableTab(title: "Abilities") {
            Text("TODO!")
        }
    }
}

struct PokemonDetail_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetail(pokemon: .example)
            .environmentObject(PokemonDataStore())
    }
}
