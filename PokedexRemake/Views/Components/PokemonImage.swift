//
//  PokemonImage.swift
//  PokedexRemake
//
//  Created by Tino on 8/10/2022.
//

import SwiftUI

struct PokemonImage: View {
    let url: URL?
    let imageSize: Double
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(width: imageSize, height: imageSize)
    }
}

struct PokemonImage_Previews: PreviewProvider {
    static var previews: some View {
        PokemonImage(url: nil, imageSize: 100)
    }
}
