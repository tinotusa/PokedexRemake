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
        do {
            self.pokemonSpecies = try await PokemonSpecies(pokemon.species.url)
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to get pokemon species from pokemon with id: \(pokemon.id)")
            viewLoadingState = .error(error: error)
        }
    }
}

struct PokemonDetail: View {
    let pokemon: Pokemon
    @StateObject private var viewModel = PokemonDetailViewModel()
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    
    // tab view models
    @StateObject private var aboutTabViewModel = AboutTabViewModel()
    @StateObject private var statsTabViewModel = StatsTabViewModel()
    @StateObject private var evolutionsTabViewModel = EvolutionsTabViewModel()
    @StateObject private var movesTabViewModel = MovesTabViewModel()
    @StateObject private var abilitiesTabViewModel = AbilitiesTabViewModel()
    
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
                 
                    AboutTab(viewModel: aboutTabViewModel, pokemon: pokemon)
                    StatsTab(viewModel: statsTabViewModel, pokemon: pokemon)
                    EvolutionsTab(viewModel: evolutionsTabViewModel, pokemon: pokemon)
                    MovesTab(viewModel: movesTabViewModel, pokemon: pokemon)
                    AbilitiesTab(viewModel: abilitiesTabViewModel, pokemon: pokemon)
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
}

struct PokemonDetail_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetail(pokemon: .example)
    }
}
