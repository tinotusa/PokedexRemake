//
//  GenerationsCategoryView.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI

struct GenerationsCategoryView: View {
    @ObservedObject var viewModel: GenerationsCategoryViewModel
    private let columns: [GridItem] = [.init(.adaptive(minimum: 200))]
    
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
                    ForEach(viewModel.sortedGenerations()) { generation in
                        GenerationCard(generation: generation)
                    }
                }
                .padding()
            }
            .navigationTitle("Generations")
            .background(Color.background)
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct GenerationsCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        GenerationsCategoryView(viewModel: GenerationsCategoryViewModel())
    }
}
