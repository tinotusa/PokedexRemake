//
//  GenerationDetail.swift
//  PokedexRemake
//
//  Created by Tino on 1/11/2022.
//

import SwiftUI
import SwiftPokeAPI

struct GenerationDetail: View {
    let generation: Generation
    @StateObject private var viewModel = GenerationDetailViewModel()
    @AppStorage(SettingsKey.language) private var languageCode = SettingsKey.defaultLanguage
    @StateObject private var movesListViewModel = MovesListViewModel()
    @StateObject private var pokemonListViewModel = PokemonListViewModel()
    @StateObject private var pokemonSpeciesListViewModel = PokemonSpeciesListViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .task {
                    await viewModel.loadData(generation: generation, languageCode: languageCode)
                }
        case . loaded:
            ScrollView {
                Grid(alignment: .topLeading) {
                    ForEach(GenerationDetailViewModel.InfoKey.allCases) { infoKey in
                        GridRow {
                            Text(infoKey.title)
                                .foregroundColor(.gray)
                            gridRowValue(for: infoKey)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(
                viewModel.mainRegion != nil ?
                viewModel.mainRegion!.localizedName(languageCode: languageCode) :
                generation.mainRegion.name!
            )
            .background(Color.background)
            .sheet(isPresented: $viewModel.showingMovesList) {
                MovesListView(
                    title: viewModel.mainRegion!.localizedName(languageCode: languageCode),
                    id: generation.id,
                    description: "Moves in this generation",
                    moveURLS: generation.moves.map { $0.url },
                    viewModel: movesListViewModel
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showingPokemonSpeciesList) {
                PokemonSpeciesListView(
                    title: generation.localizedName(languageCode: languageCode),
                    speciesURLs: generation.pokemonSpecies.map { $0.url },
                    viewModel: pokemonSpeciesListViewModel
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showingAbilitiesList) {
                AbilityListView(
                    title: generation.localizedName(languageCode: languageCode),
                    description: "Abilities introduced in this generation",
                    abilityURLS: generation.abilities.map { $0.url }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension GenerationDetail {
    @ViewBuilder
    func gridRowValue(for infoKey: GenerationDetailViewModel.InfoKey) -> some View {
        let value = viewModel.details[infoKey, default: "N/A"]
        switch infoKey {
        case .abilities:
            GridRowButton(items: generation.abilities, value: value) {
                viewModel.showingAbilitiesList = true
            }
        case .moves:
            GridRowButton(items: generation.moves, value: value) {
                viewModel.showingMovesList = true
            }
        case .pokemonSpecies:
            GridRowButton(items: generation.pokemonSpecies, value: value) {
                viewModel.showingPokemonSpeciesList = true
            }
        case .types:
            LazyVGrid(columns: [.init(.adaptive(minimum: 100))], alignment: .leading, spacing: 5) {
                if viewModel.types.isEmpty {
                    Text("N/A")
                } else {
                    ForEach(viewModel.types) { type in
                        TypeTag(type: type)
                    }
                }
            }
        case .versionGroups:
            VStack(alignment: .leading) {
                ForEach(viewModel.versions) { version in
                    Text(version.localizedName(languageCode: languageCode))
                }
            }
        default:
            Text(value)
        }
    }
}

struct GenerationDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GenerationDetail(generation: .example)
        }
    }
}
