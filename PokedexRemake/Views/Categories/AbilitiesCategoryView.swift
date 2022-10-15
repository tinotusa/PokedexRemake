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
                LazyVStack {
                    ForEach(viewModel.sortedAbilities()) { ability in
                        Text(ability.name)
                            .padding()
                    }
                    if viewModel.hasNextPage {
                        ProgressView()
                            .task {
                                await viewModel.loadNextPage()
                            }
                    }
                }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct AbilitiesCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AbilitiesCategoryView(viewModel: AbilitiesCategoryViewModel())
    }
}
