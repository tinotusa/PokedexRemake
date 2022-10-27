//
//  AbilityCard.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilityCard: View {
    let ability: Ability
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel = AbilityCardViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPlaceholder
                .task {
                    await viewModel.loadData(ability: ability)
                }
        case .loaded:
            NavigationLink(value: ability) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(ability.localizedName(languageCode: language))
                        Spacer()
                        Text(Globals.formattedID(ability.id))
                            .foregroundColor(.gray)
                    }
                    .subtitleStyle()
                    Text(ability.effectEntries.localizedEntry(language: language, shortVersion: true))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.gray)
                    Text(viewModel.localizedGenerationName(language: language))
                }
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension AbilityCard {
    var loadingPlaceholder: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Ability name")
                Spacer()
                Text("#999")
                    .foregroundColor(.gray)
            }
            .subtitleStyle()
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent sodales eu elit ac maximus.")
                .lineLimit(2)
                .foregroundColor(.gray)
            Text("Generation name")
        }
        .bodyStyle()
        .redacted(reason: .placeholder)
    }
}

struct AbilityCard_Previews: PreviewProvider {
    static var previews: some View {
        AbilityCard(ability: .example)
    }
}
