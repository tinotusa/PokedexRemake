//
//  PokemonDetail.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct LargeBlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .title2Style()
            .fontWeight(.light)
            .padding(.horizontal)
            .padding(.vertical, 3)
            .background(Color.accentColor.opacity(0.7))
            .cornerRadius(10)
    }
}

extension ButtonStyle where Self == LargeBlueButtonStyle {
    static var largeBlueButton: LargeBlueButtonStyle {
        LargeBlueButtonStyle()
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
    @StateObject private var abilitiesListViewModel = AbilitiesListViewModel()
    
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
                        .buttonStyle(.largeBlueButton)
                        
                        Button("Abilities") {
                            viewModel.showingAbiltiesSheet = true
                        }
                        .buttonStyle(.largeBlueButton)
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
                title: viewModel.pokemonSpecies.localizedName(for: language),
                description: "Moves this pokemon can learn.",
                
                viewModel: movesListViewModel,
                pokemon: pokemon
            )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showingAbiltiesSheet) {
            AbilitiesListView(
                title: viewModel.pokemonSpecies.localizedName(for: language),
                description: "Abilities this pokemon has.",
                viewModel: abilitiesListViewModel,
                pokemon: pokemon
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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
