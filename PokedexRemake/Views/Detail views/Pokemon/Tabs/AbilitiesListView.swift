//
//  AbilitiesListView.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilitiesListView: View {
    let title: String
    let description: LocalizedStringKey
    @ObservedObject var viewModel: AbilitiesListViewModel
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
            DetailListView(title: title, id: pokemon.id, description: description) {
                ForEach(viewModel.sortedAbilities()) { ability in
                    AbilityExpandableTab(ability: ability)
                }
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct AbilitiesListView_Preveiws: PreviewProvider {
    static var previews: some View {
        AbilitiesListView(
            title: "some title",
            description: "Some description here",
            viewModel: AbilitiesListViewModel(), pokemon: .example)
    }
}
