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
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel = MoveCardViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            redactedLoadingView
            .task {
                await viewModel.loadData(move: move)
            }
        case .loaded:
            NavigationLink(value: move) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(move.localizedName(for: language))
                        Spacer()
                        Text(Globals.formattedID(move.id))
                            .foregroundColor(.gray)
                    }
                    .subtitleStyle()
                    Text(
                        move.localizedEffectEntry(
                            for: language,
                            shortVersion: true,
                            effectChance: move.effectChance
                        )
                    )
                    .lineLimit(1)
                    .foregroundColor(.gray)
                    HStack {
                        TypeTag(type: viewModel.type)
                        Text(viewModel.damageClass.localizedName(for: language))
                    }
                }
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension MoveCard {
    var redactedLoadingView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Some title here")
                Spacer()
                Text("123")
                    .foregroundColor(.gray)
            }
            .subtitleStyle()
            Text("A rather short description here.")
                .lineLimit(1)
                .foregroundColor(.gray)
            HStack {
                Text("Type")
                Text("DamageClass")
            }
        }
        .redacted(reason: .placeholder)
    }
}

struct MoveCard_Previews: PreviewProvider {
    static var previews: some View {
        MoveCard(move: .example)
    }
}
