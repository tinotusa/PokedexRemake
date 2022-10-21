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
    let id: Int
    let description: LocalizedStringKey
    let entries: [VerboseEffect]
    
    @ObservedObject var viewModel: EffectEntriesListViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HeaderBar(title: title, id: id)
                Text(description)
                    .multilineTextAlignment(.leading)
                
                if entries.isEmpty {
                    Text("No entries available")
                } else {
                    ForEach(entries, id: \.self) { entry in
                        VStack {
                            Text(entry.shortEffect)
                        }
                    }
                }
            }
            .padding()
        }
        .bodyStyle()
    }
}

struct EffectEntriesListView_Previews: PreviewProvider {
    static var previews: some View {
        EffectEntriesListView(
            title: "some title",
            id: 999,
            description: "some description here.",
            entries: [],
            viewModel: EffectEntriesListViewModel()
        )
    }
}
