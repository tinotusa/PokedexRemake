//
//  LoadingView.swift
//  PokedexRemake
//
//  Created by Tino on 16/11/2022.
//

import SwiftUI

struct LoadingView: View {
    var placeholder = "Loading..."
    
    var body: some View {
        VStack {
            ProgressView()
            Text(placeholder)
        }
        .foregroundColor(.text)
        .bodyStyle()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .ignoresSafeArea()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
