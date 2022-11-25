//
//  AbilityListView.swift
//  PokedexRemake
//
//  Created by Tino on 3/11/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilityListView: View {
    let title: String
    let description: LocalizedStringKey
    
    @StateObject private var viewModel: AbilityListViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(title: String, description: LocalizedStringKey, abilityURLs: [URL]) {
        self.title = title
        self.description = description
        _viewModel = StateObject(wrappedValue: AbilityListViewModel(urls: abilityURLs))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewLoadingState {
                case .loading:
                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.loadPage()
                            }
                        }
                case .loaded:
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            Text(description)
                            Divider()
                            ForEach(viewModel.abilities) { ability in
                                AbilityCard(ability: ability)
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
                case .error(let error):
                    ErrorView(text: error.localizedDescription)
                }
            }
            .navigationTitle(title)
            .toolbar {
                Button("Close") {
                    dismiss()
                }
        }
        }
    }
}

struct AbilityListView_Previews: PreviewProvider {
    static var previews: some View {
        AbilityListView(
            title: "some title",
            description: "some description",
            abilityURLs: [
                URL(string: "https://pokeapi.co/api/v2/ability/1")!,
                URL(string: "https://pokeapi.co/api/v2/ability/2")!,
                URL(string: "https://pokeapi.co/api/v2/ability/3")!,
                URL(string: "https://pokeapi.co/api/v2/ability/4")!
            ]
        )
    }
}
