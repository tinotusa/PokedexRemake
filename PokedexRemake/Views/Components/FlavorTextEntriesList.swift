//
//  FlavorTextEntriesList.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct FlavorTextEntriesList: View {
    let abilityFlavorTexts: [AbilityFlavorText]
    
    var body: some View {
        ForEach(abilityFlavorTexts, id: \.self) { abilityFlavorText in
            Text(abilityFlavorText.flavorText)
        }
    }
}

struct FlavorTextEntriesList_Previews: PreviewProvider {
    static var previews: some View {
        FlavorTextEntriesList(abilityFlavorTexts: [])
    }
}
