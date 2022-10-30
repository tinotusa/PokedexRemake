//
//  FlavorTextEntriesList.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct CustomFlavorText: Hashable {
    let flavorText: String
    let language: NamedAPIResource
    let versionGroup: NamedAPIResource
    
    func filteredFlavorText() -> String {
        flavorText.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression)
    }
}

struct FlavorTextEntriesList: View {
    let title: String
    let id: Int
    let description: LocalizedStringKey
    let language: String
    let abilityFlavorTexts: [CustomFlavorText]
    @ObservedObject var viewModel: FlavorTextEntriesListViewModel
    
    var body: some View {
        DetailListView(title: title, id: id, description: description) {
            Group {
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
                                        Text(version.localizedName(languageCode: language))
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
    }
}

struct FlavorTextEntriesList_Previews: PreviewProvider {
    static var previews: some View {
        FlavorTextEntriesList(
            title: "a title",
            id: 999,
            description: "some description",
            language: SettingsKey.defaultLanguage,
            abilityFlavorTexts: [],
            viewModel: FlavorTextEntriesListViewModel()
        )
    }
}
