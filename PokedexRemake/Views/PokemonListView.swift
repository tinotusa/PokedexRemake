//
//  PokemonListView.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import SwiftUI

struct PokemonListView: View {
    let pokemoURLs: [URL]
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct PokemonListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView(pokemoURLs: [])
    }
}
