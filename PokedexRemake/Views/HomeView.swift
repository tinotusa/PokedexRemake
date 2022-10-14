//
//  HomeView.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var pokemonCategoryViewModel = PokemonCategoryViewModel()
    @StateObject private var moveCategoryViewModel = MoveCategoryViewModel()
    
    @State private var isShowingSearchView = false
    @Namespace private var namespace
    
    var body: some View {
        VStack {
            if isShowingSearchView {
                SearchView(showingSearchView: $isShowingSearchView, namespace: namespace)
            } else {
                homeView
            }
        }
        .navigationDestination(for: PokemonCategoryViewModel.self) { pokemonCategoryViewModel in
            PokemonCategoryView(viewModel: pokemonCategoryViewModel)
        }
        .navigationDestination(for: MoveCategoryViewModel.self) { moveCategoryViewModel in
            MoveCategoryView(viewModel: moveCategoryViewModel)
        }
    }
}

private extension HomeView {
    var homeView: some View {
        VStack(alignment: .leading) {
            Text("Search")
                .headerTextStyle()
            Button {
                withAnimation {
                    isShowingSearchView = true
                }
            } label: {
                SearchBarButton()
                    .matchedGeometryEffect(id: 1, in: namespace)
            }
            Spacer()
            Text("Categories")
                .categoryTitleStyle()
            Divider()
            CategoryGrid(
                pokemonCategoryViewModel: pokemonCategoryViewModel,
                moveCategoryViewModel: moveCategoryViewModel
            )
            Spacer()
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .environmentObject(PokemonSearchResultsViewModel())
        }
    }
}
