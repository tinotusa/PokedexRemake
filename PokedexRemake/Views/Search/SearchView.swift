//
//  SearchView.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct SearchView: View {
    @Binding var showingSearchView: Bool
    var namespace: Namespace.ID
    
    @State private var searchText = ""
    @State private var searchScope: SearchScope = .pokemon
    @FocusState private var focusedField: FocusedField?
    
    // view models
    @StateObject private var pokemonResultsViewModel = SearchResultsListViewModel<Pokemon>(saveFilename: "pokemonHistory")
    @StateObject private var moveResultsViewModel = SearchResultsListViewModel<Move>(saveFilename: "moveHistory")
    @StateObject private var itemResultsViewModel = SearchResultsListViewModel<Item>(saveFilename: "itemHistory")
    @StateObject private var abilityResultsViewModel = SearchResultsListViewModel<Ability>(saveFilename: "abilityHistory")
    @StateObject private var locationResultsViewModel = SearchResultsListViewModel<Location>(saveFilename: "locationHistory")

    var body: some View {
        VStack {
            HStack {
                SearchBar(searchScope.title, searchText: $searchText)
                    .focused($focusedField, equals: .searchBar)
                    .matchedGeometryEffect(id: 1, in: namespace)
                    .onSubmit {
                        Task {
                            await search()
                        }
                    }
                Button {
                    withAnimation {
                        showingSearchView = false
                    }
                } label: {
                    Text("Cancel")
                }
            }
            .padding([.horizontal, .top])
            
            SearchScopeTabs(selection: $searchScope)
                .padding(.horizontal)
            
            switch searchScope {
            case .pokemon:
                SearchResultsListView(viewModel: pokemonResultsViewModel) { pokemon in
                    PokemonResultRow(pokemon: pokemon)
                }
            case .moves:
                SearchResultsListView(viewModel: moveResultsViewModel) { move in
                    MoveCard(move: move)
                }
            case .items:
                SearchResultsListView(viewModel: itemResultsViewModel) { item in
                    ItemCard(item: item)
                }
            case .abilities:
                SearchResultsListView(viewModel: abilityResultsViewModel) { ability in
                    AbilityCard(ability: ability)
                }
            case .locations:
                SearchResultsListView(viewModel: locationResultsViewModel) { location in
                    LocationCard(location: location)
                }
            }
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            focusedField = .searchBar
        }
    }
}

private extension SearchView {
    func search() async {
        switch searchScope {
        case .pokemon:
            await pokemonResultsViewModel.search(searchText)
        case .moves:
            await moveResultsViewModel.search(searchText)
        case .items:
            await itemResultsViewModel.search(searchText)
        case .abilities:
            await abilityResultsViewModel.search(searchText)
        case .locations:
            await locationResultsViewModel.search(searchText)
        }
    }
}

private extension SearchView {
    enum FocusedField: Hashable {
        case searchBar
    }
    
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(showingSearchView: .constant(false), namespace: Namespace().wrappedValue)
    }
}
