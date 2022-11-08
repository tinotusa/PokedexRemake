//
//  NavigationLabel.swift
//  PokedexRemake
//
//  Created by Tino on 21/10/2022.
//

import SwiftUI

struct NavigationLabel: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .lineLimit(1)
                .layoutPriority(1)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundColor(.accentColor)
    }
}

struct NavigationLabel_Previews: PreviewProvider {
    static var previews: some View {
        NavigationLabel(title: "some title here")
    }
}
