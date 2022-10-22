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
            SearchResultsView(viewModel: viewModel) { ability in
                AbilityCard(ability: ability)
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
