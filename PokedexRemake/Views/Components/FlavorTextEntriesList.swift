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
        DetailListView(title: title, description: description) {
            Group {
                switch viewModel.viewLoadingState {
                case .loading:
                    ProgressView()
                        .task {
                            await viewModel.loadData(abilityFlavorTexts: abilityFlavorTexts)
                        }
                case .loaded:
                    VStack(alignment: .leading) {
                        ForEach(viewModel.flavorTexts, id: \.self) { flavorText in
                            let flavorTextVersionGroup = viewModel.flavorTextVersionGroups[flavorText, default: []]
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(flavorTextVersionGroup, id: \.self) { versionGroup in
                                        if let name = versionGroup.name {
                                            let versions = viewModel.versions(named: name)
                                            ForEach(versions) { version in
                                                Text(version.localizedName(languageCode: language))
                                            }
                                        }
                                    }
                                }
                                .foregroundColor(.gray)
                            }
                            Text(flavorText)
                        }
                    }
                    .bodyStyle()
                case .error(let error):
                    ErrorView(text: error.localizedDescription) {
                        Task {
                            await viewModel.loadData(abilityFlavorTexts: abilityFlavorTexts)
                        }
                    }
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
            abilityFlavorTexts: Ability.example.flavorTextEntries.map {
                CustomFlavorText(
                    flavorText: $0.flavorText,
                    language: $0.language,
                    versionGroup: $0.versionGroup
                )
            },
            viewModel: FlavorTextEntriesListViewModel()
        )
    }
}
