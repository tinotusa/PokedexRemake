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
    @Published var showingMovesSheet = false
    
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
    @StateObject private var movesListViewModel = MovesListViewModel()
    @StateObject private var abilitiesTabViewModel = AbilitiesTabViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
                    .task {
                        await viewModel.loadData(from: pokemon)
                    }
            case .loaded:
                ScrollView {
                    VStack(alignment: .leading) {
                        PokemonImage(url: pokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        nameAndID
                        
                        AboutTab(viewModel: aboutTabViewModel, pokemon: pokemon)
                        StatsTab(viewModel: statsTabViewModel, pokemon: pokemon)
                        EvolutionsTab(viewModel: evolutionsTabViewModel, pokemon: pokemon)
                        
                        Button("Moves") {
                            viewModel.showingMovesSheet = true
                        }
                        .title2Style()
                        .fontWeight(.light)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.7))
                        .cornerRadius(10)
                        
                        AbilitiesTab(viewModel: abilitiesTabViewModel, pokemon: pokemon)
                    }
                    .padding()
                }
                .bodyStyle()
            case .error(let error):
                ErrorView(text: error.localizedDescription)
            }
        }
        .sheet(isPresented: $viewModel.showingMovesSheet) {
            MovesListView(
                title: pokemon.name,
                description: "Moves this pokemon can learn.",
                
                viewModel: movesListViewModel,
                pokemon: pokemon
            )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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
