//
//  MoveCard.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MoveCard: View {
    private let move: Move
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel: MoveCardViewModel
    
    init(move: Move) {
        self.move = move
        _viewModel = StateObject(wrappedValue: MoveCardViewModel(move: move))
    }
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            placeholderLoadingView
                .onAppear {
                    Task {
                        await viewModel.loadData(languageCode: language)
                    }
                }
        case .loaded:
            NavigationLink {
                MoveDetail(move: move)
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.localizedMoveName)
                        Spacer()
                        Text(Globals.formattedID(move.id))
                            .foregroundColor(.gray)
                    }
                    .subtitleStyle()
                    Text(viewModel.localizedEffectEntry)
                    .lineLimit(1)
                    .foregroundColor(.gray)
                    if let type = viewModel.type {
                        HStack {
                            TypeTag(type: type)
                            Text(viewModel.localizedDamageClassname)
                        }
                    }
                }
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadData(languageCode: language)
                }
            }
        }
    }
}

private extension MoveCard {
    var placeholderLoadingView: some View {
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
