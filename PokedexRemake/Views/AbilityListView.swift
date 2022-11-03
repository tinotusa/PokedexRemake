//
//  AbilityListView.swift
//  PokedexRemake
//
//  Created by Tino on 3/11/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilityListView: View {
    let title: String
    let description: String
    let abilityURLS: [URL]
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct AbilityListView_Previews: PreviewProvider {
    static var previews: some View {
        AbilityListView(
            title: "some title",
            description: "some description",
            abilityURLS: Generation.example.abilities.map { $0.url }
        )
    }
}
