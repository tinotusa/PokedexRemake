//
//  PastMoveValuesListView.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PastMoveValuesListView: View {
    let title: String
    let id: Int
    let description: LocalizedStringKey
    let pastValues: [PastMoveStatValues]
    @StateObject private var viewModel = PastMoveValuesListViewModel()
    
    var body: some View {
        DetailListView(title: title, description: description) {
            Group {
                switch viewModel.viewLoadingState {
                case .loading:
                    ProgressView()
                        .task {
                            await viewModel.loadData(pastValues: pastValues)
                        }
                case .loaded:
                    ForEach(pastValues, id: \.self) { pastValue in
                        PastMoveValueView(pastValue: pastValue)
                    }
                case .error(let error):
                    ErrorView(text: error.localizedDescription)
                }
            }
        }
    }
}

struct PastMoveValuesListView_Previews: PreviewProvider {
    static var previews: some View {
        PastMoveValuesListView(
            title: "some title",
            id: 123,
            description: "some description goes here.",
            pastValues: Move.flashExample.pastValues
        )
    }
}
