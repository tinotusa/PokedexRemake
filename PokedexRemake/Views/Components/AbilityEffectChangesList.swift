//
//  AbilityEffectChangesList.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilityEffectChangesList: View {
    let effectChanges: [AbilityEffectChange]
    @StateObject private var viewModel = AbilityEffectChangesListViewModel()
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(effectChanges: effectChanges, language: language)
                }
        case .loaded:
            VStack(alignment: .leading) {
                ForEach(viewModel.localizedEffectVersions) { localizedEffectVersion in
                    HStack {
                        ForEach(localizedEffectVersion.versions) { version in
                            Text(version.localizedName(for: language))
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
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct AbilityEffectChangesList_Previews: PreviewProvider {
    static var previews: some View {
        AbilityEffectChangesList(effectChanges: [])
    }
}
