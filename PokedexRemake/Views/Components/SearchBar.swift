//
//  SearchBar.swift
//  PokedexRemake
//
//  Created by Tino on 4/10/2022.
//

import SwiftUI


struct SearchBar: View {
    let placeholder: LocalizedStringKey
    @Binding var searchText: String
    
    init(_ placeholder: LocalizedStringKey, searchText: Binding<String>) {
        self.placeholder = placeholder
        _searchText = searchText
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField(placeholder, text: $searchText)
                .autocorrectionDisabled(true)
        }
        .foregroundColor(.gray)
        .padding()
        .background(.white)
        .cornerRadius(Constants.cornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .strokeBorder(.gray.opacity(0.3), lineWidth: 2)
        }
    }
}

private extension SearchBar {
    enum Constants {
        static let cornerRadius = 10.0
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar("Search for something...", searchText: .constant(""))
    }
}
