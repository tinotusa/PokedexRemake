//
//  ErrorView.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI

struct ErrorView: View {
    let text: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(text)
            Spacer()
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(text: "preview error")
    }
}
