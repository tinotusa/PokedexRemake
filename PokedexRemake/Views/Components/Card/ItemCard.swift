//
//  ItemCard.swift
//  PokedexRemake
//
//  Created by Tino on 15/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct ItemCard: View {
    let item: Item
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel = ItemCardViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPlaceholder
                .task {
                    await viewModel.loadData(item: item)
                }
        case .loaded:
            NavigationLink(value: item) {
                HStack {
                    PokemonImage(url: item.sprites.default, imageSize: Constants.imageSize)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.localizedName(for: language))
                            Spacer()
                            Text(Globals.formattedID(item.id))
                                .foregroundColor(.gray)
                        }
                        .subtitle2Style()
                        Text(item.effectEntries.localizedEntry(language: language, shortVersion: false))
                            .lineLimit(1)
                            .foregroundColor(.gray)
                        HStack {
                            Text(viewModel.localizedItemCategoryName(language: language))
                            Spacer()
                            if item.cost != 0 {
                                Text("Cost: \(item.cost)")
                            }
                        }
                    }
                }
                .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension ItemCard {
    enum Constants {
        static let imageSize = 82.0
    }
    
    var loadingPlaceholder: some View {
        HStack {
            Image("bulbasaur")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.imageSize, height: Constants.imageSize)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Item name")
                    Spacer()
                    Text("#123")
                        .foregroundColor(.gray)
                }
                .subtitle2Style()
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ac mauris eu justo tempor pulvinar et et arcu. ")
                    .lineLimit(1)
                    .foregroundColor(.gray)
                HStack {
                    Text("some category name")
                    Spacer()
                    Text("Cost: 1234")
                }
            }
        }
        .bodyStyle()
        .redacted(reason: .placeholder)
    }
}

struct ItemCard_Previews: PreviewProvider {
    static var previews: some View {
        ItemCard(item: .example)
    }
}
