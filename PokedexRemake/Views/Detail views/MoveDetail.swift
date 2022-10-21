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
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(move: move, languageCode: language)
                }
        case .loaded:
            ScrollView {
                VStack(alignment: .leading) {
                    HeaderBar(title: move.localizedName(for: language), id: move.id)
                    
                    Grid(alignment: .leading, verticalSpacing: 8) {
                        ForEach(MoveDetailViewModel.MoveDetails.allCases) { moveDetailKey in
                            let value = viewModel.moveDetails[moveDetailKey, default: "Error"]
                            GridRow {
                                Text(moveDetailKey.title)
                                    .foregroundColor(.gray)
                                switch moveDetailKey {
                                case .type:
                                    if let type = viewModel.type {
                                        TypeTag(type: type)
                                    }
                                case .learnedByPokemon:
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
                                case .effectEntries:
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
                                case .effectChanges:
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
                                default:
                                    Text(value)
                                }
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
        case .error(let error):
            ErrorView(text: error.localizedDescription)
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
