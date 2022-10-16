//
//  AbilitiesCategoryView.swift
//  PokedexRemake
//
//  Created by Tino on 15/10/2022.
//

import SwiftUI

struct AbilitiesCategoryView: View {
    @ObservedObject var viewModel: AbilitiesCategoryViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData()
                }
        case .loaded:
            ScrollView {
                LazyVStack(spacing: Constants.spacing) {
                    ForEach(viewModel.sortedAbilities()) { ability in
                        AbilityCard(ability: ability)
                    }
                    if viewModel.hasNextPage {
                        ProgressView()
                            .task {
                                await viewModel.loadNextPage()
                            }
                    }
                }
                .padding()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension AbilitiesCategoryView {
    enum Constants {
        static let spacing = 15.0
    }
}

struct AbilitiesCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AbilitiesCategoryView(viewModel: AbilitiesCategoryViewModel())
    }
}
