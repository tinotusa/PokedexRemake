//
//  ErrorView.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI

struct ErrorView: View {
    let text: String
    var retryAction: (() -> Void)
    
    var body: some View {
        VStack {
            Spacer()
            Text(text)
            
            Button("Retry") {
                retryAction()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(text: "preview error") {
            // nothing
        }
    }
}
