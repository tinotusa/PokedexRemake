//
//  SearchView.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct SearchScopeTabs: View {
    @Binding var selection: SearchView.SearchScope
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(SearchView.SearchScope.allCases) { searchScope in
                    Button {
                        selection = searchScope
                    } label: {
                        Text(searchScope.title)
                            .bodyStyle()
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(isSelected(searchScope) ? Color.selectedTab : Color.unselectedTab)
                            .cornerRadius(7)
                    }
                }
            }
        }
    }
    
    func isSelected(_ other: SearchView.SearchScope) -> Bool {
        selection == other
    }
}

struct SearchView: View {
    @Binding var showingSearchView: Bool
    var namespace: Namespace.ID
    
    @State private var searchText = ""
    @State private var searchScope: SearchScope = .pokemon
    @FocusState private var focusedField: FocusedField?
    @EnvironmentObject private var pokemonSearchResultsViewModel: PokemonSearchResultsViewModel
    @EnvironmentObject private var pokemonDataStore: PokemonDataStore
    
    var body: some View {
        VStack {
            HStack {
                SearchBar("View model search text", searchText: $searchText)
                    .focused($focusedField, equals: .searchBar)
                    .matchedGeometryEffect(id: 1, in: namespace)
                    .onSubmit {
                        Task {
                            switch searchScope {
                            case .pokemon:
                                await pokemonSearchResultsViewModel.searchForPokemon(named: searchText, pokemonDataStore: pokemonDataStore)
                            default:
                                print("TODO!")
                            }
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

extension SearchView {
    
    enum SearchScope: String, CaseIterable, Identifiable {
        case pokemon
        case moves
        case items
        case abilities
        case locations
        case generations
        
        var id: Self { self }
        
        var title: LocalizedStringKey {
            LocalizedStringKey(self.rawValue.capitalized)
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
            .environmentObject(PokemonDataStore())
    }
}
