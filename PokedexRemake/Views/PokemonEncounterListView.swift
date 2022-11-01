//
//  PokemonEncounterListView.swift
//  PokedexRemake
//
//  Created by Tino on 31/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonEncounterListView: View {
    let locationArea: LocationArea
    let pokemonEncounters: [PokemonEncounter]
    @StateObject private var viewModel = PokemonEncounterListViewModel()
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    @State private var selectedVersion: Version?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(pokemonEncounters: pokemonEncounters)
                }
        case .loaded:
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        let name = locationArea.localizedName(languageCode: language)
                        Group {
                            if name.isEmpty {
                                Text(locationArea.name)
                            } else {
                                Text(name)
                            }
                        }
                        .title2Style()
                        
                        Text("Pokemon that can be encountered at this location.")
                        
                        HStack {
                            ForEach(viewModel.sortedVersions) { version in
                                Button {
                                    selectedVersion = version
                                } label: {
                                    Text(version.localizedName(languageCode: language))
                                }
                            }
                        }
                        
                        Grid(alignment: .center){
                            ForEach(pokemonEncounters, id: \.self) { encounter in
                                if let pokemon = viewModel.pokemon.first(where: { $0.name == encounter.pokemon.name}) {
                                    GridRow {
                                        PokemonCardView(pokemon: pokemon)
                                        encounterDetails(encounter: encounter)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .bodyStyle()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("Close") {
                        dismiss()
                    }
                }
                .onAppear {
                    selectedVersion = viewModel.sortedVersions.first
            }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension PokemonEncounterListView {
    func detailsGrid(details: VersionEncounterDetail) -> some View {
        ForEach(details.encounterDetails, id: \.self) { encounterDetails in
            Grid(alignment: .leading, verticalSpacing: 8) {
                GridRow {
                    Text("Encounter method")
                        .foregroundColor(.gray)
                    if let encounterMethod = viewModel.encounterMethods.first(where: { $0.name == encounterDetails.method.name }) {
                        Text(encounterMethod.localizedName(languageCode: language))
                    }
                }
                GridRow {
                    Text("Min level")
                        .foregroundColor(.gray)
                    Text("\(encounterDetails.minLevel)")
                }
                GridRow {
                    Text("Max level")
                        .foregroundColor(.gray)
                    Text("\(encounterDetails.maxLevel)")
                }
                GridRow {
                    Text("Chance")
                        .foregroundColor(.gray)
                    Text(encounterDetails.chance.formatted(.percent))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    func encounterDetails(encounter: PokemonEncounter) -> some View {
        if let selectedVersion {
            if let details = encounter.versionDetails.first(where: { $0.version.name == selectedVersion.name }) {
                if details.encounterDetails.count == 1 {
                    detailsGrid(details: details)
                } else {
                    TabView {
                        detailsGrid(details: details)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
                
            } else {
                Text("N/A")
            }
        } else {
            Text("Select version to view details.")
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
    }
}

struct PokemonEncounterListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PokemonEncounterListView(locationArea: .example, pokemonEncounters: LocationArea.example.pokemonEncounters)
        }
    }
}
