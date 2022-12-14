//
//  PokemonDetail.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonDetail: View {
    let pokemon: Pokemon
    @StateObject private var viewModel = PokemonDetailViewModel()
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    
    // tab view models
    @StateObject private var aboutTabViewModel = AboutTabViewModel()
    @StateObject private var statsTabViewModel = StatsTabViewModel()
    @StateObject private var evolutionsTabViewModel = EvolutionsTabViewModel()
    @StateObject private var movesListViewModel: MovesListViewModel
    @StateObject private var abilitiesListViewModel: AbilitiesListViewModel
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        _movesListViewModel = StateObject(wrappedValue: MovesListViewModel(urls: pokemon.moves.map { $0.move.url }))
        _abilitiesListViewModel = StateObject(wrappedValue: AbilitiesListViewModel(pokemon: pokemon))
    }
    
    var body: some View {
        VStack {
            switch viewModel.viewLoadingState {
            case .loading:
                LoadingView()
                    .task {
                        await viewModel.loadData(from: pokemon, languageCode: language)
                    }
            case .loaded:
                ScrollView {
                    VStack(alignment: .leading) {
                        PokemonImage(url: pokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        AboutTab(viewModel: aboutTabViewModel, pokemon: pokemon)
                        StatsTab(viewModel: statsTabViewModel, pokemon: pokemon)
                        EvolutionsTab(viewModel: evolutionsTabViewModel, pokemon: pokemon)
                        
                        DropdownButton(label: "Moves") {
                            viewModel.showingMovesSheet = true
                        }
                        
                        DropdownButton(label: "Abilities") {
                            viewModel.showingAbilitiesSheet = true
                        }
                    }
                    .padding()
                }
                .navigationTitle(viewModel.localizedName)
                .background(Color.background)
                .bodyStyle()
            case .error(let error):
                ErrorView(text: error.localizedDescription) {
                    Task {
                        await viewModel.loadData(from: pokemon, languageCode: language)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingMovesSheet) {
            MovesListView(
                title: viewModel.localizedName,
                description: "Moves this pokemon can learn.",
                viewModel: movesListViewModel
            )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showingAbilitiesSheet) {
            AbilitiesListView(
                title: viewModel.localizedName,
                description: "Abilities this pokemon has.",
                viewModel: abilitiesListViewModel
            )
            .presentationDetents([.large])
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
            Text(viewModel.localizedName)
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
        NavigationStack {
            PokemonDetail(pokemon: .example)
        }
    }
}
