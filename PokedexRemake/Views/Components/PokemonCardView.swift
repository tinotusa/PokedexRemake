//
//  PokemonCardView.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import SwiftUI
import SwiftPokeAPI
import os

final class PokemonCardViewModel: ObservableObject {
    @Published private(set) var pokemonSpecies: PokemonSpecies!
    @Published private var types: Set<`Type`>!
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private var logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "PokemonCardViewModel")
}

extension PokemonCardViewModel {
    func sortedTypes() -> [Type] {
        types.sorted()
    }
    @MainActor
    func loadData(from pokemon: Pokemon) async {
        do {
            let id = pokemon.species.url.lastPathComponent
            async let pokemonSpecies = PokemonSpecies(id)
            async let types = getTypes(from: pokemon)
            
            self.pokemonSpecies = try await pokemonSpecies
            self.types = await types
            viewLoadingState = .loaded
        } catch {
            viewLoadingState = .error(error: error)
        }
    }
    
    private func getTypes(from pokemon: Pokemon) async -> Set<`Type`> {
        await withTaskGroup(of: `Type`?.self) { group in
            for pokemonType in pokemon.types {
                group.addTask { [weak self] in
                    do {
                        guard let name = pokemonType.type.name else {
                            self?.logger.debug("Failed to get type name.")
                            return nil
                        }
                        return try await `Type`(name)
                    } catch {
                        self?.logger.debug("Failed to get type.")
                    }
                    return nil
                }
            }
            
            var types = Set<`Type`>()
            for await type in group {
                guard let type else { continue }
                types.insert(type)
            }
            return types
        }
    }
}

struct PokemonCardView: View {
    let pokemon: Pokemon
    @AppStorage(SettingKey.language.rawValue) var language = "en"
    
    @StateObject private var viewModel = PokemonCardViewModel()
    
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(from: pokemon)
                }
        case .loaded:
            NavigationLink(value: pokemon) {
                VStack(alignment: .leading) {
                    PokemonImage(url: pokemon.sprites.other.officialArtwork.frontDefault, imageSize: Constants.imageSize)
                    
                    HStack {
                        Text(viewModel.pokemonSpecies.localizedName(for: language))
                            .layoutPriority(1)
                        Text(Globals.formattedID(pokemon.id))
                            .foregroundColor(.gray)
                            .bodyStyle2()
                    }
                    .lineLimit(1)
                    
                    HStack {
                        ForEach(viewModel.sortedTypes()) { type in
                            TypeTag(type: type)
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

private extension PokemonCardView {
    enum Constants {
        static let imageSize = 120.0
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView(pokemon: .example)
    }
}
