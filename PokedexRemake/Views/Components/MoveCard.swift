//
//  MoveCard.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MoveCard: View {
    let move: Move
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    @StateObject private var viewModel = MoveCardViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(move: move)
                }
        case .loaded:
            VStack(alignment: .leading) {
                HStack {
                    Text(move.localizedName(for: language))
                    Spacer()
                    Text(Globals.formattedID(move.id))
                        .foregroundColor(.gray)
                }
                Text(move.effectEntries.first!.shortEffect)
                    .lineLimit(1)
                    .foregroundColor(.gray)
                HStack {
                    Text(move.damageClass.name!)
                    Text(move.type.name!)
                }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

struct MoveCard_Previews: PreviewProvider {
    static var previews: some View {
        MoveCard(move: .example)
    }
}
