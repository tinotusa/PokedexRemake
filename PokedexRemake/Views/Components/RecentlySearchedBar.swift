//
//  RecentlySearchedBar.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI

struct RecentlySearchedBar: View {
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text("Recently searched")
                .foregroundColor(.gray)
            Spacer()
            Button("Clear") {
                action()
            }
            .foregroundColor(.accentColor)
        }
        .bodyStyle2()
    }
}

struct RecentlySearchedBar_Previews: PreviewProvider {
    static var previews: some View {
        RecentlySearchedBar() {
            // do nothing
        }
    }
}
