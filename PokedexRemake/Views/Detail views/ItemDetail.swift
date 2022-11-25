//
//  ItemDetail.swift
//  PokedexRemake
//
//  Created by Tino on 24/10/2022.
//

import SwiftUI
import SwiftPokeAPI

extension VerboseEffect {
    enum EffectType {
        case short
        case long
    }
    
    func filteredEffect(_ effectType: EffectType = .short) -> String {
        var text = self.effect
        if effectType == .short {
            text = self.shortEffect
        }
        return text.replacingOccurrences(of: "[\\s\\n]+", with: " ", options: .regularExpression)
    }
}

struct ItemDetail: View {
    let item: Item
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel = ItemDetailViewModel()
    @StateObject private var flavorTextEntriesListViewModel = FlavorTextEntriesListViewModel()
    @StateObject private var pokemonListViewModel: PokemonListViewModel
    
    init(item: Item) {
        self.item = item
        _pokemonListViewModel = StateObject(wrappedValue: PokemonListViewModel(urls: item.heldByPokemon.map { $0.pokemon.url }))
    }
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .task {
                    await viewModel.loadData(item: item, languageCode: language)
                }
        case .loaded:
            ScrollView {
                VStack(alignment: .leading) {
                    PokemonImage(url: item.sprites.default, imageSize: Constants.imageSize)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Group {
                        Text(item.effectEntries.localizedEntry(language: language, shortVersion: true))
                        Text(item.effectEntries.localizedEntry(language: language))
                    }
                    .padding(.bottom)
                    
                    Grid(alignment: .topLeading, verticalSpacing: Constants.verticalSpacing) {
                        ForEach(ItemDetailViewModel.ItemDetailKey.allCases) { itemDetailKey in
                            GridRow {
                                Text(itemDetailKey.title)
                                    .foregroundColor(.gray)
                                
                                gridRowValue(for: itemDetailKey)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(item.localizedName(languageCode: language))
            .background(Color.background)
            .sheet(isPresented: $viewModel.showingFlavorTextList) {
                FlavorTextEntriesList(
                    title: item.localizedName(languageCode: language),
                    id: item.id,
                    description: "Flavor texts for this item",
                    language: language,
                    abilityFlavorTexts: viewModel.localizedFlavorTextEntries.map { entry in
                        CustomFlavorText (flavorText: entry.text, language: entry.language, versionGroup: entry.versionGroup)
                    },
                    viewModel: flavorTextEntriesListViewModel
                )
            }
            .sheet(isPresented: $viewModel.showingMachinesList) {
                MachinesListView(
                    title: item.localizedName(languageCode: language),
                    description: "Machines related to this item.",
                    urls: item.machines.map { $0.machine.url }
                )
            }
            .sheet(isPresented: $viewModel.showingPokemonList) {
                PokemonListView(
                    title: item.localizedName(languageCode: language),
                    description: "Pokemon that hold this item",
                    viewModel: pokemonListViewModel
                )
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension ItemDetail {
    enum Constants {
        static let imageSize = 120.0
        static let verticalSpacing = 8.0
    }
    
    @ViewBuilder
    func gridRowValue(for itemDetailKey: ItemDetailViewModel.ItemDetailKey) -> some View {
        let value = viewModel.itemDetails[itemDetailKey, default: "N/A"]
        Group {
            switch itemDetailKey {
            case .attributes:
                attributesView()
            case .flavorTextEntries:
                flavorTextEntriesView(value: value)
            case .heldByPokemon:
                heldByPokemonView(value: value)
            default:
                Text(viewModel.itemDetails[itemDetailKey, default: "N/A"])
            }
        }
        .foregroundColor(value == "N/A" ? .gray : .text)
    }
    
    @ViewBuilder
    func attributesView() -> some View {
        if viewModel.attributes.isEmpty {
            Text("N/A")
                .foregroundColor(.gray)
        } else {
            VStack(alignment: .leading) {
                ForEach(viewModel.attributes) { attribute in
                    Text(attribute.localizedName(languageCode: language))
                }
            }
        }
    }
    
    @ViewBuilder
    func flavorTextEntriesView(value: String) -> some View {
        if viewModel.localizedFlavorTextEntries.isEmpty {
            Text(value)
        } else {
            Button {
                viewModel.showingFlavorTextList = true
            } label: {
                NavigationLabel(title: value)
            }
        }
    }
    
    @ViewBuilder
    func heldByPokemonView(value: String) -> some View {
        if item.heldByPokemon.isEmpty {
            Text(value)
        } else {
            Button {
                viewModel.showingPokemonList = true
            } label: {
                NavigationLabel(title: value)
            }
        }
    }
    
    @ViewBuilder
    func machinesView(value: String) -> some View {
        if item.machines.isEmpty {
            Text(value)
        } else {
            Button {
                viewModel.showingMachinesList = true
            } label: {
                NavigationLabel(title: value)
            }
        }
    }
}

struct ItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ItemDetail(item: .example)
        }
    }
}
