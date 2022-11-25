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
    
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        DetailListView(title: title, description: description) {
            Group {
                switch viewModel.viewLoadingState {
                case .loading:
                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.loadPage()
                            }
                        }
                case .loaded:
                    ForEach(viewModel.abilities) { ability in
                        AbilityExpandableTab(ability: ability)
                    }
                    .bodyStyle()
                case .error(let error):
                    ErrorView(text: error.localizedDescription) {
                        Task {
                            await viewModel.loadPage()
                        }
                    }
                }
            }
        }
    }
}

struct AbilitiesListView_Preveiws: PreviewProvider {
    static var previews: some View {
        AbilitiesListView(
            title: "some title",
            description: "Some description here",
            viewModel: AbilitiesListViewModel(pokemon: .example)
        )
    }
}
