//
//  AbilityDetail.swift
//  PokedexRemake
//
//  Created by Tino on 30/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilityDetail: View {
    private let ability: Ability
    @StateObject private var viewModel: AbilityDetailViewModel
    
    @StateObject private var abilityEffectChangesListViewModel = AbilityEffectChangesListViewModel()
    @StateObject private var flavorTextEntriesListViewModel = FlavorTextEntriesListViewModel()
    @StateObject private var pokemonListViewModel: PokemonListViewModel
    
    init(ability: Ability) {
        self.ability = ability
        _viewModel = StateObject(wrappedValue: AbilityDetailViewModel(ability: ability))
        _pokemonListViewModel = StateObject(wrappedValue: PokemonListViewModel(urls: ability.pokemon.map { $0.pokemon.url }))
    }
    
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .task {
                    await viewModel.loadData(languageCode: language)
                }
        case .loaded:
            ScrollView {
                VStack(alignment: .leading) {
                    Grid(alignment: .leading, verticalSpacing: Constants.verticalSpacing) {
                        ForEach(AbilityDetailViewModel.AbilityDetailKey.allCases) { abilityDetailKey in
                            GridRow {
                                Text(abilityDetailKey.title)
                                    .foregroundColor(.gray)
                                gridRowValue(for: abilityDetailKey)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.abilityName)
            .background(Color.background)
            .bodyStyle()
            .sheet(isPresented: $viewModel.showingEffectEntriesListView) {
                EffectEntriesListView(
                    title: viewModel.abilityName,
                    description: "Effect entries for this ability",
                    entries: ability.effectEntries.localizedItems(for: language)
                )
            }
            .sheet(isPresented: $viewModel.showingEffectChangesListView) {
                AbilityEffectChangesList(
                    title: viewModel.abilityName,
                    id: ability.id,
                    description: "Effect changes for this ability.",
                    effectChanges: ability.effectChanges,
                    language: language,
                    viewModel: abilityEffectChangesListViewModel
                )
            }
            .sheet(isPresented: $viewModel.showingFlavorTextEntriesListView) {
                FlavorTextEntriesList(
                    title: viewModel.abilityName,
                    id: ability.id,
                    description: "Flavor text entries for this ability.",
                    language: language,
                    abilityFlavorTexts: viewModel.customFlavorTexts,
                    viewModel: flavorTextEntriesListViewModel
                )
            }
            .sheet(isPresented: $viewModel.showingPokemonListView) {
                PokemonListView(
                    title: viewModel.abilityName,
                    description: "Pokemon with this ability",
                    viewModel: pokemonListViewModel
                )
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadData(languageCode: language)
                }
            }
        }
    }
}

struct GridRowButton<T: Collection>: View {
    let items: T
    let value: String
    let action: () -> Void
    
    var body: some View {
        if items.count == 0 {
            Text(value)
        } else {
            Button {
                action()
            } label: {
                NavigationLabel(title: value)
                    .foregroundColor(.accentColor)
            }
            
        }
    }
}

private extension AbilityDetail {
    enum Constants {
        static let verticalSpacing = 8.0
    }
    @ViewBuilder
    func gridRowValue(for key: AbilityDetailViewModel.AbilityDetailKey) -> some View {
        let value = viewModel.abilityDetails[key, default: "N/A"]
        switch key {
        case .effectEntries:
            GridRowButton(items: viewModel.localizedEffectEntries, value: value) {
                viewModel.showingEffectEntriesListView = true
            }
        case .effectChanges:
            GridRowButton(items: ability.effectChanges, value: value) {
                viewModel.showingEffectChangesListView = true
            }
        case .flavorTextEntries:
            GridRowButton(items: ability.flavorTextEntries, value: value) {
                viewModel.showingFlavorTextEntriesListView = true
            }
        case .pokemon:
            GridRowButton(items: ability.pokemon, value: value) {
                viewModel.showingPokemonListView = true
            }
        default:
            Text(value)
        }
    }
}

struct AbilityDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AbilityDetail(ability: .example)
        }
    }
}
