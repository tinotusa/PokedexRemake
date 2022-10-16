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
            ProgressView()
                .task {
                    await viewModel.loadData()
                }
        case .loaded:
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.sortedLocations()) { location in
                        Text(location.name)
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

struct LocationsCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsCategoryView(viewModel: LocationsCategoryViewModel())
    }
}
