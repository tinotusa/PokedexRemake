//
//  LocationCard.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct LocationCard: View {
    private let location: Location
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel: LocationCardViewModel
    
    init(location: Location) {
        self.location = location
        _viewModel = StateObject(wrappedValue: LocationCardViewModel(location: location))
    }
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPlaceholder
                .onAppear {
                    Task {
                        await viewModel.loadData(languageCode: language)
                    }
                }
        case .loaded:
            NavigationLink {
                LocationDetail(location: location)
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.locationName)
                        Spacer()
                        Text(Globals.formattedID(location.id))
                            .foregroundColor(.gray)
                    }
                    .subtitleStyle()
                    Text(viewModel.regionName)
                }
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadData(languageCode: language)
                }
            }
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
