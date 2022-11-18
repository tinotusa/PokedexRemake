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
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    @State private var selectedVersion: Version?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .onAppear {
                    Task {
                        await viewModel.loadData(pokemonEncounters: pokemonEncounters)
                        selectedVersion = viewModel.sortedVersions.first
                    }
                }
        case .loaded:
            NavigationStack {
                ScrollView {
                    LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                        Text("Pokemon that can be encountered at this location.")
                        Divider()
                        Section(header: versionTabs) {
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
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .bodyStyle()
                .navigationBarTitle(locationName)
                .toolbar {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension PokemonEncounterListView {
    var locationName: String {
        let name = locationArea.localizedName(languageCode: language)
        if name.isEmpty {
            return locationArea.name
        }
        return name
    }
    
    func detailsGrid(details: VersionEncounterDetail) -> some View {
        // Different pokemon can have the same encounter details
        // since they are the same I can't make them Identifiable.
        // This seems like the best solution.
        ForEach(Array(details.encounterDetails.enumerated()), id: \.0) { index, encounterDetails in
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
    
    var versionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.sortedVersions) { version in
                    Button {
                        selectedVersion = version
                    } label: {
                        Text(version.localizedName(languageCode: language))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(selectedVersion == version ? Color.selectedTab : Color.unselectedTab)
                    .foregroundColor(colorScheme == .dark && selectedVersion != version ?  Color.unselectedTabText : Color.selectedTabText)
                    .cornerRadius(5)
                }
            }
            .padding(.vertical)
        }
        .background(Color.background)
    }
}

struct PokemonEncounterListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PokemonEncounterListView(locationArea: .example, pokemonEncounters: LocationArea.example.pokemonEncounters)
        }
    }
}
