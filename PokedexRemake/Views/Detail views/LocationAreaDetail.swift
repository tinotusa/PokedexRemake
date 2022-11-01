//
//  LocationAreaDetail.swift
//  PokedexRemake
//
//  Created by Tino on 31/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct LocationAreaDetail: View {
    let locationArea: LocationArea
    @AppStorage(SettingsKey.language.rawValue) private var languageCode = SettingsKey.defaultLanguage
    @StateObject private var viewModel = LocationAreaDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(locationArea: locationArea)
                }
        case .loaded:
            NavigationStack {
                ScrollView {
                    Grid(alignment: .topLeading, verticalSpacing: 8) {
                        GridRow {
                            Text("Name")
                                .foregroundColor(.gray)
                            Text(locationArea.filteredName(languageCode: languageCode))
                        }
                        GridRow {
                            Text("Encounter method rates")
                                .foregroundColor(.gray)
                            if viewModel.encounterVersions.isEmpty {
                                Text("N/A")
                            } else {
                                VStack(alignment: .leading) {
                                    ForEach(viewModel.encounterVersions) { encounterVersion in
                                        Text(encounterVersion.encounterMethod.localizedName(languageCode: languageCode))
                                        ForEach(encounterVersion.versionDetails, id: \.version) { details in
                                            HStack {
                                                Text(details.rate.formatted(.percent))
                                                Text(details.version.localizedName(languageCode: languageCode))
                                            }
                                        }
                                        Divider()
                                    }
                                }
                            }
                        }
                        GridRow {
                            Text("Pokemon encounters")
                                .foregroundColor(.gray)
                            Button {
                                viewModel.showingPokemonList = true
                            } label: {
                                NavigationLabel(title: "\(locationArea.pokemonEncounters.count)")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .bodyStyle()
                .navigationBarTitle(locationArea.filteredName(languageCode: languageCode))
                .toolbar {
                    Button("Close") {
                        dismiss()
                    }
                }
                .sheet(isPresented: $viewModel.showingPokemonList) {
                    PokemonEncounterListView(
                        locationArea: locationArea,
                        pokemonEncounters: locationArea.pokemonEncounters
                    )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct LocationAreaDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LocationAreaDetail(locationArea: .example)
        }
    }
}
