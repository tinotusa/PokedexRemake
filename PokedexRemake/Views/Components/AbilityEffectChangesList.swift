//
//  AbilityEffectChangesList.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilityEffectChangesList: View {
    let title: String
    let id: Int
    let description: LocalizedStringKey
    let effectChanges: [AbilityEffectChange]
    let language: String
    
    @ObservedObject var viewModel: AbilityEffectChangesListViewModel
    
    var body: some View {        
        DetailListView(
            title: title,
            description: description
        ) {
            Group {
                switch viewModel.viewLoadingState {
                case .loading:
                    ProgressView()
                        .task {
                            await viewModel.loadData(effectChanges: effectChanges, languageCode: language)
                        }
                case .loaded:
                    VStack(alignment: .leading) {
                        ForEach(viewModel.localizedEffectVersions) { localizedEffectVersion in
                            HStack {
                                ForEach(localizedEffectVersion.versions) { version in
                                    Text(version.localizedName(languageCode: language))
                                }
                            }
                            .foregroundColor(.gray)
                            ForEach(localizedEffectVersion.effectEntries, id: \.self) { entry in
                                Text(entry.effect)
                            }
                        }
                        Divider()
                    }
                    .bodyStyle()
                case .error(let error):
                    ErrorView(text: error.localizedDescription) {
                        Task {
                            await viewModel.loadData(effectChanges: effectChanges, languageCode: language)
                        }
                    }
                }
            }
        }
    }
}

struct AbilityEffectChangesList_Previews: PreviewProvider {
    static var previews: some View {
        AbilityEffectChangesList(
            title: "A title",
            id: 999,
            description: "some description",
            effectChanges: [],
            language: SettingsKey.defaultLanguage,
            viewModel: AbilityEffectChangesListViewModel()
        )
    }
}
