//
//  SearchBarButton.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct SearchBarButton: View {
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            Text("Pokemon, moves, and more")
        }
        .foregroundColor(.gray)
        .frame(maxWidth: .infinity, alignment: .leading)
        .bodyStyle()
        .padding()
        .background(Color.searchBarBackground)
        .cornerRadius(Constants.cornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .strokeBorder(.gray.opacity(0.5), lineWidth: 2)
        }
    }
}

private extension SearchBarButton {
    enum Constants {
        static let cornerRadius = 13.0
    }
}

struct SearchBarButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            SearchBarButton()
        }
    }
}
