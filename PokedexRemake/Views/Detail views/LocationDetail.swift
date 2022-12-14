//
//  LocationDetail.swift
//  PokedexRemake
//
//  Created by Tino on 30/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct LocationDetail: View {
    let location: Location
    @StateObject private var viewModel = LocationDetailViewModel()
    @State private var selectedArea: LocationArea?
    
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .task {
                    await viewModel.loadData(location: location)
                }
        case .loaded:
            ScrollView {
                VStack(alignment: .leading) {
                    Grid(alignment: .topLeading) {
                        regionRow
                        areasRow
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .bodyStyle()
            .navigationTitle(
                location.localizedName(languageCode: language).isEmpty ? location.name : location.localizedName(languageCode: language)
            )
            .background(Color.background)
            .sheet(item: $selectedArea) { area in
                LocationAreaDetail(locationArea: area)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadData(location: location)
                }
            }
        }
    }
}

private extension LocationDetail {
    var regionRow: some View {
        GridRow {
            Text("Region")
                .foregroundColor(.gray)
            if let region = viewModel.region {
                Text(region.localizedName(languageCode: language))
            } else {
                Text("N/A")
                    .foregroundColor(.gray)
            }
        }
    }
    
    var areasRow: some View {
        GridRow {
            Text("Areas")
                .foregroundColor(.gray)
            if viewModel.areas.isEmpty {
                Text("N/A")
                    .foregroundColor(.gray)
            } else {
                VStack(alignment: .leading) {
                    ForEach(viewModel.areas) { area in
                        Button {
                            selectedArea = area
                        } label: {
                            if let name = area.localizedName(languageCode: language),
                               !name.isEmpty
                            {
                                Text(name)
                            } else {
                                Text(area.name)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LocationDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LocationDetail(location: .example)
        }
    }
}
