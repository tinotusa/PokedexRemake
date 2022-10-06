//
//  AboutTab.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AboutTab: View {
    private let pokemonData: PokemonData
    private let pokemonSpecies: PokemonSpecies
    
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    
    @StateObject private var viewModel = AboutTabViewModel()
    @EnvironmentObject private var pokemonDataStore: PokemonDataStore
    
    init(pokemonData: PokemonData) {
        self.pokemonData = pokemonData
        self.pokemonSpecies = pokemonData.pokemonSpecies
    }
    
    var body: some View {
        ExpandableTab(title: "About") {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
                    .task {
                        await viewModel.loadData(pokemonDataStore: pokemonDataStore, pokemonData: pokemonData)
                    }
            case .loaded:
                VStack(alignment: .leading) {
                    entriesList
                    showMoreButtonRow
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
                                        ForEach(pokemonData.types) { type in
                                            TypeTag(type: type)
                                        }
                                    }
                                case .heldItems:
                                    if pokemonData.pokemon.heldItems.isEmpty {
                                        Text("0 items")
                                    } else {
                                        if let items = pokemonDataStore.items(for: pokemonData.pokemon) {
                                            VStack(alignment: .leading) {
                                                ForEach(Array(items)) { item in
                                                    Text(item.localizedName(for: language))
                                                }
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
                ErrorView(text: error.localizedDescription)
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
        let entries = pokemonSpecies.flavorTextEntries.localizedEntries(language: language)
        ForEach(viewModel.showEntries(from: entries)) { flavorText in
            VStack(alignment: .leading) {
                if let name = flavorText.version?.name,
                   let version = pokemonDataStore.versions.first(where: { $0.name == name })
                {
                    Text(version.localizedName(for: language))
                }
                Text(flavorText.filteredText())
                Divider()
            }
        }
    }
}

struct AboutTab_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            AboutTab(pokemonData: .init(
                pokemon: .example,
                pokemonSpecies: .example,
                types: [.grassExample, .poisonExample],
                generation: .example
            ))
        }
        .environmentObject(PokemonDataStore())
    }
}
