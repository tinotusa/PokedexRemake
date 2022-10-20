//
//  MoveDetail.swift
//  PokedexRemake
//
//  Created by Tino on 20/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MoveDetail: View {
    let move: Move
    @StateObject private var viewModel = MoveDetailViewModel()
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(move: move, languageCode: language)
                }
        case .loaded:
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(move.localizedName(for: language))
                        Spacer()
                        Text(Globals.formattedID(move.id))
                    }
                    .titleStyle()
                    
                    Grid(alignment: .leading, verticalSpacing: 5) {
                        ForEach(MoveDetailViewModel.MoveDetails.allCases) { moveDetailKey in
                            GridRow {
                                Text(moveDetailKey.title)
                                    .foregroundColor(.gray)
                                switch moveDetailKey {
                                case .type:
                                    if let type = viewModel.type {
                                        TypeTag(type: type)
                                    }
                                case .learnedByPokemon:
                                    HStack {
                                        Text(viewModel.moveDetails[moveDetailKey, default: "Error"])
                                        Spacer()
                                        Button {
                                            // todo
                                        } label: {
                                            Image(systemName: "chevron.right")
                                        }
                                        .foregroundColor(.accentColor)
                                    }
                                default:
                                    Text(viewModel.moveDetails[moveDetailKey, default: "N/A"])
                                }
                                
                            }
                        }
                    }
                    if move.meta != nil {
                        Text("Meta details")
                            .title2Style()
                            .fontWeight(.light)
                        Grid(alignment: .leading, verticalSpacing: 5) {
                            ForEach(MoveDetailViewModel.MoveMetaDetails.allCases) { metaDetailKey in
                                GridRow {
                                    Text(metaDetailKey.title)
                                        .foregroundColor(.gray)
                                    switch metaDetailKey {
                                    default: Text(viewModel.metaDetails[metaDetailKey, default: "N/A"])
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct MoveDetail_Previews: PreviewProvider {
    static var previews: some View {
        MoveDetail(move: .example)
    }
}
