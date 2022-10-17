//
//  EmptySearchHistoryView.swift
//  PokedexRemake
//
//  Created by Tino on 17/10/2022.
//

import SwiftUI

struct EmptySearchHistoryView: View {
    let text: LocalizedStringKey
    var errorMessage: String?
    
    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .foregroundColor(.gray)
                .bodyStyle()
                .multilineTextAlignment(.center)
            
            SearchErrorView(text: errorMessage)
            
            Spacer()
        }
    }
}

struct EmptySearchHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        EmptySearchHistoryView(text: "Search for something.")
    }
}
