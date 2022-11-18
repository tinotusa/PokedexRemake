//
//  LocationsCategoryView.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct LocationsCategoryView: View {
    @ObservedObject var viewModel: LocationsCategoryViewModel
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .onAppear {
                    Task {
                        await viewModel.loadData()
                    }
                }
        case .loaded:
            ScrollView {
                LazyVStack(spacing: Constants.spacing) {
                    ForEach(viewModel.sortedLocations()) { location in
                        LocationCard(location: location)
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
            .navigationTitle("Locations")
            .background(Color.background)
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
        
    }
}

private extension LocationsCategoryView {
    enum Constants {
        static let spacing = 10.0
    }
}

struct LocationsCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsCategoryView(viewModel: LocationsCategoryViewModel())
    }
}
