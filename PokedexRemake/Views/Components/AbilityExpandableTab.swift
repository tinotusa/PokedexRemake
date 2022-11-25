//
//  AbilityExpandableTab.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilityExpandableTab: View {
    let ability: Ability
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel = AbilityExpandableTabViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(ability: ability, languageCode: language)
                }
        case .loaded:
            VStack(alignment: .leading) {
                HStack {
                    Text(ability.localizedName(languageCode: language))
                    Spacer()
                    Text(Globals.formattedID(ability.id))
                        .foregroundColor(.gray)
                }
                .subtitleStyle()
                Text(viewModel.localizedGenerationName)
                    .foregroundColor(.gray)
                if ability.effectEntries.isEmpty {
                    Text("No description.")
                        .foregroundColor(.gray)
                } else {
                    Text(ability.effectEntries.localizedEntry(language: language, shortVersion: true))
                }
                
                if viewModel.showLongerEffectEntry {
                    Divider()
                    Text(ability.effectEntries.localizedEntry(language: language))
                }
                
                showMoreButton
                // TODO: Use navigation to list views 
//                ExpandableTab(title: "Effect changes", isSubheader: true) {
//                    if ability.effectChanges.isEmpty {
//                        Text("No changes.")
//                            .foregroundColor(.gray)
//                    } else {
//                        AbilityEffectChangesList(effectChanges: ability.effectChanges)
//                    }
//                }
//                .padding(.leading)
//
//                ExpandableTab(title: "Flavor text entries", isSubheader: true) {
//                    FlavorTextEntriesList(abilityFlavorTexts: viewModel.localizedFlavorTextEntries)
//                }
//                .padding(.leading)
                Divider()
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension AbilityExpandableTab {
    var showMoreButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    viewModel.showLongerEffectEntry.toggle()
                }
            } label: {
                Text(viewModel.showLongerEffectEntry ? "Show less" : "Show more")
            }
            .foregroundColor(.accentColor)
        }
    }
}

struct AbilityExpandableTab_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            AbilityExpandableTab(ability: .example)
        }
    }
}
