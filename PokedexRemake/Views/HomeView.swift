//
//  HomeView.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct HomeView: View {
    @State private var isShowingSearchView = false
    @Namespace private var namespace
    
    // MARK: - Category view models
    @StateObject private var pokemonCategoryViewModel = PokemonCategoryViewModel()
    @StateObject private var moveCategoryViewModel = MoveCategoryViewModel()
    @StateObject private var itemsCategoryViewModel = ItemsCategoryViewModel()
    @StateObject private var abilitiesCategoryViewModel = AbilitiesCategoryViewModel()
    @StateObject private var locationsCategoryViewModel = LocationsCategoryViewModel()
    @StateObject private var generationsCategoryViewModel = GenerationsCategoryViewModel()
    @AppStorage(SettingsKey.isDarkMode.rawValue) private var isDarkMode = SettingsKey.defaultIsDarkMode
    
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
                .preferredColorScheme(isDarkMode ? .dark : .light)
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationDestination(for: PokemonCategoryViewModel.self) { pokemonCategoryViewModel in
                PokemonCategoryView(viewModel: pokemonCategoryViewModel)
            }
            .navigationDestination(for: MoveCategoryViewModel.self) { moveCategoryViewModel in
                MoveCategoryView(viewModel: moveCategoryViewModel)
            }
            .navigationDestination(for: ItemsCategoryViewModel.self) { itemsCategoryViewModel in
                ItemsCategoryView(viewModel: itemsCategoryViewModel)
            }
            .navigationDestination(for: AbilitiesCategoryViewModel.self) { abilitiesCategoryViewModel in
                AbilitiesCategoryView(viewModel: abilitiesCategoryViewModel)
            }
            .navigationDestination(for: LocationsCategoryViewModel.self) { locationsCategoryViewModel in
                LocationsCategoryView(viewModel: locationsCategoryViewModel)
            }
            .navigationDestination(for: GenerationsCategoryViewModel.self) { generationsCategoryViewModel in
                GenerationsCategoryView(viewModel: generationsCategoryViewModel)
            }
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
            Spacer()
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(PokemonResultsViewModel())
        }
    }
}
