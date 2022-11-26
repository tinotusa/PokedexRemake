//
//  MoveDetail.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MoveDetail: View {
    private let move: Move
    
    @StateObject private var viewModel: MoveDetailViewModel
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    @StateObject private var pokemonListViewModel: PokemonListViewModel
    @StateObject private var abilityEffectChangesListViewModel = AbilityEffectChangesListViewModel()
    @StateObject private var flavorTextEntriesListViewModel = FlavorTextEntriesListViewModel()
    
    @State private var showingPokemonListView = false
    @State private var showingEffectEntries = false
    @State private var showingEffectChanges = false
    @State private var showingFlavorTextEntries = false
    @State private var showingMachinesListView = false
    @State private var showingPastValuesView = false
    @State private var showingStatChanges = false
    
    init(move: Move) {
        self.move = move
        _viewModel = StateObject(wrappedValue: MoveDetailViewModel(move: move))
        _pokemonListViewModel = StateObject(wrappedValue: PokemonListViewModel(urls: move.learnedByPokemon.urls()))
    }
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .task {
                    await viewModel.loadData(languageCode: language)
                }
        case .loaded:
            moveDetailsGrid
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadData(languageCode: language)
                }
            }
        }
    }
}

private extension MoveDetail {
    enum Constants {
        static let verticalSpacing = 8.0
    }
}

private extension MoveDetail {
    var moveDetailsGrid: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                Grid(alignment: .leading, verticalSpacing: Constants.verticalSpacing) {
                    ForEach(MoveDetailViewModel.MoveDetails.allCases) { moveDetailKey in
                        let value = viewModel.moveDetails[moveDetailKey, default: "N/A"]
                        GridRow {
                            Text(moveDetailKey.title)
                                .foregroundColor(.gray)
                            gridRowValue(for: moveDetailKey)
                                .foregroundColor(value == "N/A" ? .gray : .text)
                        }
                    }
                }
                if move.meta != nil {
                    Text("Meta details")
                        .title2Style()
                        .fontWeight(.light)
                    Grid(alignment: .leading, verticalSpacing: Constants.verticalSpacing) {
                        ForEach(MoveDetailViewModel.MoveMetaDetails.allCases) { metaDetailKey in
                            let value = viewModel.metaDetails[metaDetailKey, default: "N/A"]
                            GridRow {
                                Text(metaDetailKey.title)
                                    .foregroundColor(.gray)
                                Text(value)
                                    .foregroundColor(value == "N/A" ? .gray : .text)
                            }
                        }
                    }
                }
            }
            .padding()
            .bodyStyle()
        }
        .navigationTitle(viewModel.moveName)
        .background(Color.background)
        .sheet(isPresented: $showingPokemonListView) {
            PokemonListView(
                title: viewModel.moveName,
                description: "Pokemon that can learn this move.",
                viewModel: pokemonListViewModel
            )
        }
        .sheet(isPresented: $showingEffectEntries) {
            EffectEntriesListView(
                title: viewModel.moveName,
                description: "Effect entries for this move",
                effectChance: move.effectChance,
                entries: move.effectEntries
            )
        }
        .sheet(isPresented: $showingEffectChanges) {
            AbilityEffectChangesList(
                title: viewModel.moveName,
                id: move.id,
                description: "Effect changes for this move.",
                effectChanges: move.effectChanges,
                language: language,
                viewModel: abilityEffectChangesListViewModel
            )
        }
        .sheet(isPresented: $showingFlavorTextEntries) {
            FlavorTextEntriesList(
                title: viewModel.moveName,
                id: move.id,
                description: "Flavor text entries for this move.",
                language: language,
                abilityFlavorTexts: viewModel.customFlavorTexts,
                viewModel: flavorTextEntriesListViewModel
            )
        }
        .sheet(isPresented: $showingMachinesListView) {
            MachinesListView(
                title: viewModel.moveName,
                description: "Machines that teach this move.",
                urls: move.machines.map { $0.machine.url}
            )
        }
        .sheet(isPresented: $showingPastValuesView) {
            PastMoveValuesListView(
                title: viewModel.moveName,
                id: move.id,
                description: "This move's changed stat values from different games.",
                pastValues: move.pastValues
            )
        }
        .sheet(isPresented: $showingStatChanges) {
            MoveStatChangeListView(
                title: viewModel.moveName,
                id: move.id,
                description: "The stats this moves changes.",
                statChanges: move.statChanges
            )
        }
    }
    
    func learnedByPokemonNavigationLink(value: String) -> some View {
        Button {
            showingPokemonListView = true
        } label: {
            NavigationLabel(title: value)
        }
    }
    
    func effectEntriesNavigationLink(value: String) -> some View {
        Button {
            showingEffectEntries = true
        } label: {
            NavigationLabel(title: value)
        }
    }
    
    @ViewBuilder
    func effectChangesNavigationLink(value: String) -> some View {
        if move.effectChanges.isEmpty {
            Text(value)
        } else {
            Button {
                showingEffectChanges = true
            } label: {
                NavigationLabel(title: value)
            }
        }
    }
    
    @ViewBuilder
    func flavorTextEntriesNavigationLink(value: String) -> some View {
        if viewModel.localizedFlavorTextEntries.isEmpty {
            Text(value)
        } else {
            Button {
                showingFlavorTextEntries = true
            } label: {
                NavigationLabel(title: value)
            }
        }
    }
    
    @ViewBuilder
    func gridRowValue(for moveDetailKey: MoveDetailViewModel.MoveDetails) -> some View {
        let value = viewModel.moveDetails[moveDetailKey, default: "N/A"]
        switch moveDetailKey {
        case .type:
            if let type = viewModel.type {
                TypeTag(type: type)
            }
        case .learnedByPokemon:
            learnedByPokemonNavigationLink(value: value)
        case .effectEntries:
            effectEntriesNavigationLink(value: value)
        case .effectChanges:
            effectChangesNavigationLink(value: value)
        case .flavorTextEntries:
            flavorTextEntriesNavigationLink(value: value)
        case .machines:
            machinesNavigationLink(value: value)
        case .pastValues:
            pastValuesNavigationLink(value: value)
        case .statChanges:
            statChangesNavigationLink(value: value)
        default:
            Text(value)
        }
    }
    
    @ViewBuilder
    func machinesNavigationLink(value: String) -> some View {
        if move.machines.isEmpty {
            Text(value)
        } else {
            Button {
                showingMachinesListView = true
            } label: {
                NavigationLabel(title: value)
            }
        }
    }
    
    @ViewBuilder
    func pastValuesNavigationLink(value: String) -> some View {
        if move.pastValues.isEmpty {
            Text(value)
        } else {
            Button {
                showingPastValuesView = true
            } label: {
                NavigationLabel(title: value)
            }
        }
    }
    
    @ViewBuilder
    func statChangesNavigationLink(value: String) -> some View {
        if move.statChanges.isEmpty {
            Text(value)
        } else {
            Button {
                showingStatChanges = true
            } label: {
                NavigationLabel(title: value)
            }
        }
    }
}

struct MoveDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MoveDetail(move: .example)
        }
    }
}
