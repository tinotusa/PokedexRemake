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
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel: AbilityCardViewModel
    
    init(ability: Ability) {
        self.ability = ability
        _viewModel = StateObject(wrappedValue: AbilityCardViewModel(ability: ability))
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
                AbilityDetail(ability: ability)
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.abilityName)
                        Spacer()
                        Text(Globals.formattedID(ability.id))
                            .foregroundColor(.gray)
                    }
                    .subtitleStyle()
                    Text(viewModel.effectEntry)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.gray)
                    Text(viewModel.generationName)
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
