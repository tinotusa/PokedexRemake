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
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(locationArea: locationArea)
                }
        case .loaded:
            ScrollView {
                Grid(alignment: .topLeading, verticalSpacing: 8) {
                    GridRow {
                        Text("Name")
                            .foregroundColor(.gray)
                        let name = locationArea.localizedName(languageCode: languageCode)
                        if name.isEmpty {
                            Text(locationArea.name)
                        } else {
                            Text(name)
                        }
                    }
                    GridRow {
                        Text("Encounter method rates")
                            .foregroundColor(.gray)
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
                    GridRow {
                        Text("Pokemon encounters")
                            .foregroundColor(.gray)
                        NavigationLink {
                            PokemonEncounterListView(
                                locationArea: locationArea,
                                pokemonEncounters: locationArea.pokemonEncounters
                            )
                        } label: {
                            NavigationLabel(title: "\(locationArea.pokemonEncounters.count)")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .bodyStyle()
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