//
//  AbilitiesListView.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilitiesListView: View {
    @ObservedObject var viewModel: AbilitiesTabViewModel
    let pokemon: Pokemon
    
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(pokemon: pokemon)
                }
        case .loaded:
            ForEach(viewModel.sortedAbilities()) { ability in
                AbilityExpandableTab(ability: ability)
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct AbilitiesTab_Preveiws: PreviewProvider {
    static var previews: some View {
        AbilitiesListView(viewModel: AbilitiesTabViewModel(), pokemon: .example)
    }
}
