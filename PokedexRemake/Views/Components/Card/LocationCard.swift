//
//  LocationCard.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct LocationCard: View {
    let location: Location
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel = LocationCardViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPlaceholder
                .onAppear {
                    Task {
                        await viewModel.loadData(location: location)
                    }
                }
        case .loaded:
            NavigationLink {
                LocationDetail(location: location)
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text(location.localizedName(languageCode: language))
                        Spacer()
                        Text(Globals.formattedID(location.id))
                            .foregroundColor(.gray)
                    }
                    .subtitleStyle()
                    if let region = viewModel.region {
                        Text(region.localizedName(languageCode: language))
                    }
                }
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension LocationCard {
    var loadingPlaceholder: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("some name")
                Spacer()
                Text("#234")
                    .foregroundColor(.gray)
            }
            .subtitleStyle()
            Text("Region")
        }
        .bodyStyle()
        .redacted(reason: .placeholder)
    }
}

struct LocationCard_Previews: PreviewProvider {
    static var previews: some View {
        LocationCard(location: .example)
    }
}
