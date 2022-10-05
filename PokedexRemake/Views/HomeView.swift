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
    
    var body: some View {
        VStack {
            if isShowingSearchView {
                SearchView(showingSearchView: $isShowingSearchView, namespace: namespace)
            } else {
                homeView
            }
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
            CategoryGrid()
            Spacer()
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .environmentObject(PokemonSearchResultsViewViewModel())
        }
    }
}
