//
//  HomeView.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct HomeView: View {
    @State private var isShowingSearchView = false
    @Namespace private var namespace
    
    // MARK: - Category view models
    @StateObject private var pokemonCategoryViewModel = CategoryViewModel<Pokemon>()
    @StateObject private var moveCategoryViewModel = CategoryViewModel<Move>()
    @StateObject private var itemsCategoryViewModel = CategoryViewModel<Item>()
    @StateObject private var abilitiesCategoryViewModel = CategoryViewModel<Ability>()
    @StateObject private var locationsCategoryViewModel = CategoryViewModel<Location>()
    @StateObject private var generationsCategoryViewModel = CategoryViewModel<Generation>()
    
    @State private var showingSettings = false
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    if isShowingSearchView {
                        SearchView(showingSearchView: $isShowingSearchView, namespace: namespace)
                    } else {
                        homeView
                    }
                }
                .frame(width: proxy.size.width)
                .frame(minHeight: proxy.size.height)
                .navigationTitle("Search")
                .toolbar {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
            .background(Color.background)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

private extension HomeView {
    var homeView: some View {
        VStack(alignment: .leading) {
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
                moveCategoryViewModel: moveCategoryViewModel,
                itemsCategoryViewModel: itemsCategoryViewModel,
                abilitiesCategoryViewModel: abilitiesCategoryViewModel,
                locationsCategoryViewModel: locationsCategoryViewModel,
                generationsCategoryViewModel: generationsCategoryViewModel
            )
            .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
        }
    }
}
