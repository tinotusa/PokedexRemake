//
//  CategoryView.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct CategoryView<T: Hashable & Codable & SearchableByURL & Identifiable & Comparable, Content: View>: View {
    @ObservedObject var viewModel: CategoryViewModel<T>
    let title: String
    let content: (T) -> Content

    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .onAppear {
                    Task {
                        await viewModel.loadPage()
                    }
                }
        case .loaded:
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.values) { item  in
                        content(item)
                    }
                    if viewModel.pageInfo.hasNextPage {
                        ProgressView()
                            .task {
                                await viewModel.loadPage()
                            }
                    }
                }
                .padding()
            }
            .navigationTitle(title)
            .background(Color.background)
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadPage()
                }
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CategoryView(viewModel: CategoryViewModel<Pokemon>(), title: "Pokemon") { pokemon in
                PokemonResultRow(pokemon: pokemon)
            }
        }
    }
}
