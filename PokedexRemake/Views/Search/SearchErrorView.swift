//
//  SearchErrorView.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI

struct SearchErrorView: View {
    let text: String?
    
    var body: some View {
        if let text {
            Text(text)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
    }
}

struct SearchErrorView_Previews: PreviewProvider {
    static var previews: some View {
        SearchErrorView(text: "some error")
    }
}
