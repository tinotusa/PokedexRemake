//
//  AbilityCard.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilityCard: View {
    let ability: Ability
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    @StateObject private var viewModel = AbilityCardViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(ability: ability, language: language)
                }
        case .loaded:
            VStack(alignment: .leading) {
                HStack {
                    Text(ability.localizedName(for: language))
                    Spacer()
                    Text(Globals.formattedID(ability.id))
                        .foregroundColor(.gray)
                }
                .subtitleStyle()
                Text(viewModel.generation.localizedName(for: language))
                    .foregroundColor(.gray)
                if ability.effectEntries.isEmpty {
                    Text("No description.")
                        .foregroundColor(.gray)
                } else {
                    Text(ability.localizedEffectEntry(for: language, shortVersion: true))
                }
                
                if viewModel.showLongerEffectEntry {
                    Divider()
                    Text(ability.localizedEffectEntry(for: language, shortVersion: false))
                }
                
                showMoreButton
                
                ExpandableTab(title: "Effect changes", isSubheader: true) {
                    if ability.effectChanges.isEmpty {
                        Text("No changes.")
                            .foregroundColor(.gray)
                    } else {
                        AbilityEffectChangesList(effectChanges: ability.effectChanges)
                    }
                }
                .padding(.leading)
                
                ExpandableTab(title: "Flavor text entries", isSubheader: true) {
                    FlavorTextEntriesList(abilityFlavorTexts: viewModel.localizedFlavorTextEntries)
                }
                .padding(.leading)
                Divider()
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension AbilityCard {
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

struct AbilityCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            AbilityCard(ability: .example)
        }
    }
}
