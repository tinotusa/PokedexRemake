//
//  MoveStatChangeListView.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MoveStatChangeListView: View {
    let title: String
    let id: Int
    let description: LocalizedStringKey
    let statChanges: [MoveStatChange]
    
    var body: some View {
        DetailListView(
            title: title,
            id: id,
            description: description
        ) {
            ForEach(statChanges, id: \.self) { statChange in
                MoveStatChangeView(statChange: statChange)
            }
        }
    }
}

struct MoveStatChangeListView_Previews: PreviewProvider {
    static var previews: some View {
        MoveStatChangeListView(
            title: "some title",
            id: 123,
            description: "description here",
            statChanges: Move.flashExample.statChanges
        )
    }
}
