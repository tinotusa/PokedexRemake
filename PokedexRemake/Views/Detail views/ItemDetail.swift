//
//  ItemDetail.swift
//  PokedexRemake
//
//  Created by Tino on 24/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct ItemDetail: View {
    let item: Item
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    @StateObject private var viewModel = ItemDetailViewModel()
    @StateObject private var flavorTextEntriesListViewModel = FlavorTextEntriesListViewModel()
    @StateObject private var pokemonListViewModel = PokemonListViewModel()
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(item: item, languageCode: language)
                }
        case .loaded:
            ScrollView {
                VStack(alignment: .leading) {
                    PokemonImage(url: item.sprites.default, imageSize: Constants.imageSize)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    HeaderBar(title: item.localizedName(for: language), id: item.id)
                    
                    // FIXME: Change me
                    Text(item.effectEntries.first!.shortEffect)
                    Text(item.effectEntries.first!.effect)
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
            .sheet(isPresented: $viewModel.showingFlavorTextList) {
                FlavorTextEntriesList(
                    title: item.localizedName(for: language),
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
                    title: item.localizedName(language: language),
                    id: item.id,
                    description: "Machines related to this item.",
                    machineURLs: item.machines.map { $0.machine.url }
                )
            }
            .sheet(isPresented: $viewModel.showingPokemonList) {
                PokemonListView(
                    title: item.localizedName(for: language),
                    id: item.id,
                    description: "Pokemon that hold this item",
                    pokemonURLs: item.heldByPokemon.map { $0.pokemon.url },
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
    
    func attributesView() -> some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.attributes) { attribute in
                Text(attribute.names.localizedName(language: language, default: attribute.name))
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
