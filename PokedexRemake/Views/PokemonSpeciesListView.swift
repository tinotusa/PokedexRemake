//
//  PokemonSpeciesListView.swift
//  PokedexRemake
//
//  Created by Tino on 2/11/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PokemonSpeciesListView: View {
    let title: String
    @ObservedObject var viewModel: PokemonSpeciesListViewModel
    @AppStorage(SettingsKey.language) private var languageCode = SettingsKey.defaultLanguage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .onAppear {
                    Task {
                        await viewModel.loadPage()
                    }
                }
        case .loaded:
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: [.init(.adaptive(minimum: 100))]) {
                        ForEach(viewModel.pokemonDataArray) { pokemonGroup in
                            VStack(spacing: 0) {
                                AsyncImage(url: pokemonGroup.pokemon.sprites.frontDefault) { image in
                                    image
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                Text(pokemonGroup.pokemonSpecies.localizedName(languageCode: languageCode))
                                    .padding()
                            }
                        }
                        if viewModel.hasNextPage {
                            ProgressView()
                                .onAppear {
                                    Task {
                                        await viewModel.loadPage()
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .bodyStyle()
                .navigationTitle(title)
                .toolbar {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadPage()
                }
            }
        }
    }
}

struct PokemonSpeciesListView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonSpeciesListView(
            title: "Test title",
            viewModel: PokemonSpeciesListViewModel(pokemonSpeciesURLs: Generation.example.pokemonSpecies.map { $0.url })
        )
    }
}
