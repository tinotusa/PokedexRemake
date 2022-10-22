//
//  AbilityResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import SwiftUI

struct AbilityResultsView: View {
    @ObservedObject var viewModel: AbilityResultsViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    viewModel.loadData()
                }
        case .loaded:
            SearchResultsView(
                items: viewModel.abilities,
                emptyPlaceholderText: "Search for an ability",
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.errorMessage
            ) { ability in
                AbilityCard(ability: ability)
            } clearHistory: {
                viewModel.clearHistory()
            } moveToTop: { ability in
                viewModel.moveAbilityToTop(ability)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct AbilityResultsView_Previews: PreviewProvider {
    static var previews: some View {
        AbilityResultsView(viewModel: AbilityResultsViewModel())
    }
}
