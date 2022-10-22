//
//  MoveDetail.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MoveDetail: View {
    let move: Move
    @StateObject private var viewModel = MoveDetailViewModel()
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    @StateObject private var pokemonListViewModel = PokemonListViewModel()
    @StateObject private var effectEntriesListViewModel = EffectEntriesListViewModel()
    @StateObject private var abilityEffectChangesListViewModel = AbilityEffectChangesListViewModel()
    @StateObject private var flavorTextEntriesListViewModel = FlavorTextEntriesListViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingView
        case .loaded:
            moveDetailsGrid
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension MoveDetail {
    var loadingView: some View {
        ProgressView()
            .task {
                await viewModel.loadData(move: move, languageCode: language)
            }
    }
    
    var moveDetailsGrid: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HeaderBar(title: move.localizedName(for: language), id: move.id)
                
                Grid(alignment: .leading, verticalSpacing: 8) {
                    ForEach(MoveDetailViewModel.MoveDetails.allCases) { moveDetailKey in
                        GridRow {
                            Text(moveDetailKey.title)
                                .foregroundColor(.gray)
                            gridRowValue(for: moveDetailKey)
                        }
                    }
                }
                if move.meta != nil {
                    Text("Meta details")
                        .title2Style()
                        .fontWeight(.light)
                    Grid(alignment: .leading, verticalSpacing: 8) {
                        ForEach(MoveDetailViewModel.MoveMetaDetails.allCases) { metaDetailKey in
                            GridRow {
                                Text(metaDetailKey.title)
                                    .foregroundColor(.gray)
                                switch metaDetailKey {
                                default: Text(viewModel.metaDetails[metaDetailKey, default: "N/A"])
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .bodyStyle()
        }
    }
    
    func learnedByPokemonNavigationLink(value: String) -> some View {
        NavigationLink {
            PokemonListView(
                title: move.localizedName(for: language),
                id: move.id,
                description: "Pokemon that can learn this move.",
                pokemonURLs: move.learnedByPokemon.map { $0.url },
                viewModel: pokemonListViewModel
            )
        } label: {
            NavigationLabel(title: value)
        }
    }
    
    func effectEntriesNavigationLink(value: String) -> some View {
        NavigationLink {
            EffectEntriesListView(
                title: move.localizedName(for: language),
                id: move.id,
                description: "Effect entries for this moe",
                entries: move.effectEntries,
                viewModel: effectEntriesListViewModel
            )
        } label: {
            NavigationLabel(title: value)
        }
    }
    
    @ViewBuilder
    func effectChangesNavigationLink(value: String) -> some View {
        if move.effectChanges.isEmpty {
            Text(value)
        } else {
            NavigationLink {
                AbilityEffectChangesList(
                    title: move.localizedName(for: language),
                    id: move.id,
                    description: "Effect changes for this move.",
                    effectChanges: move.effectChanges,
                    language: language,
                    viewModel: abilityEffectChangesListViewModel
                )
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
            NavigationLink {
                FlavorTextEntriesList(
                    title: move.localizedName(for: language),
                    id: move.id,
                    description: "Flavor text entries for this move.",
                    language: language,
                    // TODO: does it make more sense/ is more efficient to do this in the view model (the mapping).
                    abilityFlavorTexts: viewModel.localizedFlavorTextEntries.map { entry in
                        CustomFlavorText(
                            flavorText: entry.flavorText,
                            language: entry.language,
                            versionGroup: entry.versionGroup
                        )
                    },
                    viewModel: flavorTextEntriesListViewModel
                )
            } label: {
                NavigationLabel(title: value)
            }
        }
    }
    
    @ViewBuilder
    func gridRowValue(for moveDetailKey: MoveDetailViewModel.MoveDetails) -> some View {
        let value = viewModel.moveDetails[moveDetailKey, default: "Error"]
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
            NavigationLink {
                MachinesListView(
                    title: move.localizedName(for: language),
                    id: move.id,
                    description: "Machines that teach this move.",
                    machineURLs: move.machines.map { $0.machine.url}
                )
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
            NavigationLink {
                PastMoveValuesListView(
                    title: move.localizedName(for: language),
                    id: move.id,
                    description: "This move's changed stat values from different games.",
                    pastValues: move.pastValues
                )
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
            NavigationLink {
                MoveStatChangeListView(
                    title: move.localizedName(for: language),
                    id: move.id,
                    description: "Stat changes for this move.",
                    statChanges: move.statChanges
                )
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
