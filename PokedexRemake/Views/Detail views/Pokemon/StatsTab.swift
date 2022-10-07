//
//  StatsTab.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import SwiftUI
import Charts

struct StatsTab: View {
    let pokemonData: PokemonData
    @StateObject private var viewModel = StatsTabViewModel()
    @EnvironmentObject private var pokemonDataStore: PokemonDataStore
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    
    var body: some View {
        ExpandableTab(title: "Stats") {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
                    .task {
                        await viewModel.loadData(
                            pokemonData: pokemonData,
                            pokemonDataStore: pokemonDataStore,
                            language: language
                        )
                    }
            case .loaded:
                VStack(alignment: .leading) {
                    Chart {
                        ForEach(viewModel.data) { statData in
                            BarMark(
                                x: .value("Stat name", statData.localizedName),
                                y: .value("Stat value", statData.value)
                            )
                            .foregroundStyle(by: .value("Stat name", statData.localizedName))
                        }
                    }
                    .chartForegroundStyleScale([
                        viewModel.data[0].localizedName: Color("hp"),
                        viewModel.data[1].localizedName: Color("attack"),
                        viewModel.data[2].localizedName: Color("defense"),
                        viewModel.data[3].localizedName: Color("special-attack"),
                        viewModel.data[4].localizedName: Color("special-defense"),
                        viewModel.data[5].localizedName: Color("speed"),
                    ])
                    .frame(height: 250)
                    
                    Text("Damage relations")
                        .subtitleStyle()
                    
                    Grid(alignment: .topLeading, verticalSpacing: 15) {
                        ForEach(StatsTabViewModel.TypeRelationKey.allCases) { typeRelationKey in
                            GridRow {
                                Text(typeRelationKey.title)
                                    .foregroundColor(.gray)
                                LazyVGrid(columns: [.init(.adaptive(minimum: 70))], alignment: .leading, spacing: 5) {
                                    let types = viewModel.damageRelations[typeRelationKey, default: []]
                                    if types.isEmpty {
                                        Text("No types.")
                                            .foregroundColor(.gray)
                                    } else {
                                        ForEach(types) { damageRelation in
                                            TypeTag(type: damageRelation)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            case .error(let error):
                ErrorView(text: error.localizedDescription)
            }
        }
    }
}

struct StatsTab_Previews: PreviewProvider {
    static var previews: some View {
        StatsTab(pokemonData:
            .init(
                pokemon: .example,
                pokemonSpecies: .example,
                types: [.grassExample, .poisonExample],
                generation: .example
            )
        )
        .environmentObject(PokemonDataStore())
    }
}
