//
//  FlavorTextEntriesList.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct FlavorTextEntriesList: View {
    let abilityFlavorTexts: [AbilityFlavorText]
    @StateObject private var viewModel = FlavorTextEntriesListViewModel()
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(abilityFlavorTexts: abilityFlavorTexts)
                }
        case .loaded:
            VStack(alignment: .leading) {
                ForEach(abilityFlavorTexts, id: \.self) { abilityFlavorText in
                    if let versions = viewModel.versions(named: abilityFlavorText.versionGroup.name) {
                        HStack {
                            ForEach(versions) { version in
                                Text(version.localizedName(for: language))
                            }
                        }
                        .foregroundColor(.gray)
                    }
                    Text(abilityFlavorText.filteredFlavorText())
                }
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct FlavorTextEntriesList_Previews: PreviewProvider {
    static var previews: some View {
        FlavorTextEntriesList(abilityFlavorTexts: [])
    }
}
