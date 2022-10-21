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
                    HStack {
                        Text(move.localizedName(for: language))
                        Spacer()
                        Text(Globals.formattedID(move.id))
                    }
                    .titleStyle()
                    
                    Grid(alignment: .leading, verticalSpacing: 5) {
                        ForEach(MoveDetailViewModel.MoveDetails.allCases) { moveDetailKey in
                            GridRow {
                                Text(moveDetailKey.title)
                                    .foregroundColor(.gray)
                                switch moveDetailKey {
                                case .type:
                                    if let type = viewModel.type {
                                        TypeTag(type: type)
                                    }
                                case .learnedByPokemon:
                                    NavigationLink(value: pokemonListViewModel) {
                                        NavigationLabel(title: viewModel.moveDetails[moveDetailKey, default: "Error"])
                                    }
                                case .effectEntries:
                                    NavigationLink(value: effectEntriesListViewModel) {
                                        NavigationLabel(title: viewModel.moveDetails[moveDetailKey, default: "Error"])
                                    }
                                default:
                                    Text(viewModel.moveDetails[moveDetailKey, default: "N/A"])
                                }
                                
                            }
                        }
                    }
                    if move.meta != nil {
                        Text("Meta details")
                            .title2Style()
                            .fontWeight(.light)
                        Grid(alignment: .leading, verticalSpacing: 5) {
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
            .navigationDestination(for: PokemonListViewModel.self) { viewModel in
                PokemonListView(
                    title: move.localizedName(for: language),
                    id: move.id,
                    description: "Pokemon that can learn this move.",
                    pokemonURLs: move.learnedByPokemon.map { $0.url },
                    viewModel: viewModel
                )
            }
            .navigationDestination(for: EffectEntriesListViewModel.self) { viewModel in
                EffectEntriesListView(
                    title: move.localizedName(for: language),
                    id: move.id,
                    description: "Effect entries for this move.",
                    entries: move.effectEntries,
                    viewModel: viewModel
                )
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
