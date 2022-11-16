//
//  CategoryGridCard.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct CategoryGridCard: View {
    let title: LocalizedStringKey
    
    var body: some View {
        Text(title)
            .lineLimit(1)
            .title2Style()
            .frame(maxWidth: 200, maxHeight: 60)
            .minimumScaleFactor(0.5)
            .padding()
            .foregroundColor(Color.text)
            .background(Color.secondaryBackground)
            .cornerRadius(15)
            .shadow(
                color: .black.opacity(0.1),
                radius: 2,
                x: 0,
                y: 4
            )
    }
}

private extension CategoryGridCard {
    enum Constants {
        static let cornerRadius = 10.0
    }
}

struct CategoryGridCard_Previews: PreviewProvider {
    static var previews: some View {
        CategoryGridCard(title: "Pokemon")
    }
}
