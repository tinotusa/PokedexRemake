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
    // TODO: Does this need to be in the environment? 
    @EnvironmentObject private var pokemonSearchResultsViewModel: PokemonSearchResultsViewModel
    
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
                PokemonSearchResultsView(viewModel: pokemonSearchResultsViewModel)
            default:
                Text("TODO!")
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
            await pokemonSearchResultsViewModel.searchForPokemon(named: searchText)
        default:
            print("TODO!")
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
            .environmentObject(PokemonSearchResultsViewModel())
    }
}
