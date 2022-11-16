//
//  ItemsCategoryView.swift
//  PokedexRemake
//
//  Created by Tino on 15/10/2022.
//

import SwiftUI

struct ItemsCategoryView: View {
    @ObservedObject var viewModel: ItemsCategoryViewModel
    
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
                    ForEach(viewModel.sortedItems()) { item in
                        ItemCard(item: item)
                    }
                    if viewModel.hasNextPage {
                        ProgressView()
                            .task {
                                await viewModel.getNextPageItems()
                            }
                    }
                }
                .padding([.top, .bottom, .trailing])
            }
            .navigationTitle("Items")
            .background(Color.background)
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct ItemsCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ItemsCategoryView(viewModel: ItemsCategoryViewModel())
    }
}
