//
//  PokemonDetail.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI
import SwiftPokeAPI

// TODO: Move me
struct DropdownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.accentColor)
        }
        .title2Style()
        .fontWeight(.light)
    }
}

extension ButtonStyle where Self == DropdownButtonStyle {
    static var dropDownButtonStyle: DropdownButtonStyle {
        DropdownButtonStyle()
    }
}

struct PokemonDetail: View {
    let pokemon: Pokemon
    @StateObject private var viewModel = PokemonDetailViewModel()
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    
    // tab view models
    @StateObject private var aboutTabViewModel = AboutTabViewModel()
    @StateObject private var statsTabViewModel = StatsTabViewModel()
    @StateObject private var evolutionsTabViewModel = EvolutionsTabViewModel()
    @StateObject private var movesListViewModel: MovesListViewModel
    @StateObject private var abilitiesListViewModel = AbilitiesListViewModel()
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        _movesListViewModel = StateObject(wrappedValue: MovesListViewModel(urls: pokemon.moves.map { $0.move.url }))
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
                        
                        Button("Moves") {
                            viewModel.showingMovesSheet = true
                        }
                        .buttonStyle(.dropDownButtonStyle)
                        
                        Button("Abilities") {
                            viewModel.showingAbilitiesSheet = true
                        }
                        .buttonStyle(.dropDownButtonStyle)
                    }
                    .padding()
                }
                .navigationTitle(viewModel.localizedName)
                .background(Color.background)
                .bodyStyle()
            case .error(let error):
                ErrorView(text: error.localizedDescription)
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
