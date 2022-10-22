//
//  PastMoveValueView.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PastMoveValueView: View {
    let pastValue: PastMoveStatValues
    @StateObject private var viewModel = PastMoveValueViewModel()
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    @StateObject private var effectEntriesListViewModel = EffectEntriesListViewModel()
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(pastValue: pastValue)
                }
        case .loaded:
            VStack(alignment: .leading) {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        versionsList
                    }
                    VStack {
                        versionsList
                    }
                }
                .subtitleStyle()
                
                Grid(alignment: .leading) {
                    ForEach(PastMoveValueViewModel.PastValueKey.allCases) { pastValueKey in
                        let value = viewModel.pastValues[pastValueKey, default: "N/A"]
                        GridRow {
                            Text(pastValueKey.title)
                                .foregroundColor(.gray)
                            switch pastValueKey {
                            case .type where value != "N/A":
                                if let type = viewModel.type {
                                    TypeTag(type: type)
                                }
                            case .effectEntries where value != "N/A":
                                if pastValue.effectEntries.isEmpty {
                                    Text(value)
                                } else {
                                    NavigationLink {
                                        EffectEntriesListView(
                                            title: "Past entries",
                                            id: 0,
                                            description: "Past entries for this move",
                                            entries: pastValue.effectEntries, viewModel: effectEntriesListViewModel
                                        )
                                    } label: {
                                        NavigationLabel(title: value)
                                    }
                                }
                            default: Text(value)
                                    .foregroundColor(value == "N/A" ? .gray : .text)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension PastMoveValueView {
    var versionsList: some View {
        ForEach(viewModel.sortedVersion()) { version in
            Text(version.localizedName(for: language))
        }
    }
}

struct PastMoveValueView_Previews: PreviewProvider {
    static var previews: some View {
        PastMoveValueView(pastValue: Move.flashExample.pastValues.first!)
    }
}
