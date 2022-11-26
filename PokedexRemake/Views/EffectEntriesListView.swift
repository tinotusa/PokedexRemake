//
//  EffectEntriesListView.swift
//  PokedexRemake
//
//  Created by Tino on 21/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct EffectEntriesListView: View {
    let title: String
    let description: LocalizedStringKey
    var effectChance: Int? = nil
    let entries: [VerboseEffect]
    
    var body: some View {
        DetailListView(title: title, description: description) {
            VStack(alignment: .leading) {
                if entries.isEmpty {
                    Text("No entries available")
                } else {
                    ForEach(entries, id: \.self) { entry in
                        VStack {
                            Text(entry.filteredEffect(.short, effectChance: effectChance))
                        }
                    }
                }
            }
        }
        .bodyStyle()
    }
}

struct EffectEntriesListView_Previews: PreviewProvider {
    static var previews: some View {
        EffectEntriesListView(
            title: "some title",
            description: "some description here.",
            effectChance: 12,
            entries: []
        )
    }
}
