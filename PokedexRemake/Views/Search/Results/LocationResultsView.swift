//
//  LocationResultsView.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import SwiftUI

struct LocationResultsView: View {
    @ObservedObject var viewModel: LocationResultsViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    viewModel.loadData()
                }
        case .loaded:
            SearchResultsView(
                items: viewModel.locations,
                emptyPlaceholderText: "Search for a location",
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.errorMessage
            ) { location in
                LocationCard(location: location)
            } clearHistory: {
                viewModel.clearHistory()
            } moveToTop: { location in
                viewModel.moveLocationToTop(location)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct LocationResultsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationResultsView(viewModel: LocationResultsViewModel())
    }
}
