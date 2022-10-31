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
    
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(location: location)
                }
        case .loaded:
            ScrollView {
                VStack(alignment: .leading) {
                    HeaderBar(title: location.localizedName(languageCode: language), id: location.id)
                    Grid(alignment: .topLeading) {
                        regionRow
                        areasRow
                    }
                }
                .padding()
            }
            .bodyStyle()
            .sheet(item: $selectedArea) { area in
                LocationAreaDetail(locationArea: area)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
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
            }
        }
    }
    
    var areasRow: some View {
        GridRow {
            Text("Areas")
                .foregroundColor(.gray)
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

struct LocationDetail_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetail(location: .example)
    }
}
