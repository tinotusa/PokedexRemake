//
//  HeaderBar.swift
//  PokedexRemake
//
//  Created by Tino on 21/10/2022.
//

import SwiftUI

struct HeaderBar: View {
    let title: String
    let id: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .lineLimit(1)
                    .layoutPriority(1)
                Spacer()
                Text(Globals.formattedID(id))
                    .foregroundColor(.gray)
                    .fontWeight(.light)
            }
            .titleStyle()
            
            Divider()
        }
    }
}

struct HeaderBar_Previews: PreviewProvider {
    static var previews: some View {
        HeaderBar(title: "some title", id: 999)
    }
}
