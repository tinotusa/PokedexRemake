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
        case  .loading:
            ProgressView()
                .task {
                    viewModel.loadData()
                }
        case .loaded:
            if viewModel.abilities.isEmpty {
                EmptySearchHistoryView(
                    text: "Search for an item.",
                    isLoading: viewModel.isLoading,
                    errorMessage: viewModel.errorMessage
                )
            } else {
                ScrollView {
                    LazyVStack {
                        RecentlySearchedBar {
                            viewModel.showingClearHistoryDialog = true
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                        }
                        
                        SearchErrorView(text: viewModel.errorMessage)
                        
                        ForEach(viewModel.abilities) { ability in
                            AbilityCard(ability: ability)
                                .simultaneousGesture(
                                    TapGesture()
                                        .onEnded {
                                            viewModel.moveAbilityToTop(ability)
                                        }
                                )
                        }
                    }
                }
                .confirmationDialog(
                    "Clear abilities history?",
                    isPresented: $viewModel.showingClearHistoryDialog
                ) {
                    Button("Clear history", role: .destructive) {
                        viewModel.clearHistory()
                    }
                } message: {
                    Text("Clear abilities history")
                }
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
