//
//  AboutTab.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AboutTab: View {
    @ObservedObject var viewModel: AboutTabViewModel
    let pokemon: Pokemon
    
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage

    var body: some View {
        ExpandableTab(title: "About") {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
                    .task {
                        await viewModel.loadData(pokemon: pokemon, languageCode: language)
                    }
            case .loaded:
                VStack(alignment: .leading) {
                    entriesList
                    Text("Details")
                        .subtitleStyle()
                    Grid(alignment: .topLeading) {
                        ForEach(AboutTabViewModel.AboutInfo.allCases) { aboutInfoKey in
                            GridRow {
                                Text(aboutInfoKey.title)
                                    .foregroundColor(.gray)
                                switch aboutInfoKey {
                                case .types:
                                    HStack {
                                        ForEach(Globals.sortedTypes(viewModel.types)) { type in
                                            TypeTag(type: type)
                                        }
                                    }
                                case .heldItems:
                                    if pokemon.heldItems.isEmpty {
                                        Text("0 items")
                                    } else {
                                        VStack(alignment: .leading) {
                                            ForEach(Array(viewModel.items)) { item in
                                                Text(item.localizedName(languageCode: language))
                                            }
                                        }
                                    }
                                default:
                                    Text(viewModel.aboutInfo[aboutInfoKey, default: "Error"])
                                }
                            }
                        }
                    }
                }
            case .error(error: let error):
                ErrorView(text: error.localizedDescription) {
                    Task {
                        await viewModel.loadData(pokemon: pokemon, languageCode: language)
                    }
                }
            }
        }
        .bodyStyle()
    }
}

private extension AboutTab {
    var showMoreButtonRow: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    viewModel.showAllEntries.toggle()
                }
            } label: {
                Text(viewModel.showAllEntries ? "Show less" : "Show more")
            }
            .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder
    var entriesList: some View {
        if viewModel.showAllEntries {
            ForEach(viewModel.flavorTextEntries) { flavorText in
                VStack(alignment: .leading) {
                    if let name = flavorText.version?.name,
                       let version = viewModel.versions.first(where: { $0.name == name })
                    {
                        Text(version.localizedName(languageCode: language))
                    }
                    Text(flavorText.filteredText())
                    Divider()
                }
            }
        } else {
            ForEach(viewModel.flavorTextEntries[0..<viewModel.minEntryCount]) { flavorText in
                VStack(alignment: .leading) {
                    if let name = flavorText.version?.name,
                       let version = viewModel.versions.first(where: { $0.name == name })
                    {
                        Text(version.localizedName(languageCode: language))
                    }
                    Text(flavorText.filteredText())
                    Divider()
                }
            }
        }
        if viewModel.flavorTextEntries.count > viewModel.minEntryCount {
            showMoreButtonRow
        }
    }
}

struct AboutTab_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            AboutTab(viewModel: AboutTabViewModel(), pokemon: .example)
        }
    }
}
