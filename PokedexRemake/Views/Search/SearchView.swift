//
//  SearchView.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct SearchView: View {
    @Binding var showingSearchView: Bool
    var namespace: Namespace.ID
    
    @State private var searchText = ""
    @State private var searchScope: SearchScope = .pokemon
    @FocusState private var focusedField: FocusedField?
    
    // view models
    @StateObject private var pokemonResultsViewModel = PokemonResultsViewModel()
    @StateObject private var moveResultsViewModel = MoveResultsViewModel()
    @StateObject private var itemResultsViewModel = ItemResultsViewModel()
    @StateObject private var abilityResultsViewModel = AbilityResultsViewModel()
    @StateObject private var locationResultsViewModel = LocationResultsViewModel()

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
            
            SearchScopeTabs(selection: $searchScope)
            
            switch searchScope {
            case .pokemon:
                PokemonResultsView(viewModel: pokemonResultsViewModel)
            case .moves:
                MoveResultsView(viewModel: moveResultsViewModel)
            case .items:
                ItemResultsView(viewModel: itemResultsViewModel)
            case .abilities:
                AbilityResultsView(viewModel: abilityResultsViewModel)
            case .locations:
                LocationResultsView(viewModel: locationResultsViewModel)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            focusedField = .searchBar
        }
    }
}

private extension SearchView {
    func search() async {
        switch searchScope {
        case .pokemon:
            await pokemonResultsViewModel.searchForPokemon(named: searchText)
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
