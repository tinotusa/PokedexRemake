//
//  EvolutionDetailView.swift
//  PokedexRemake
//
//  Created by Tino on 8/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct EvolutionDetailView: View {
    let evolutionDetail: EvolutionDetail
    @StateObject private var viewModel = EvolutionDetailViewModel()
    @AppStorage(SettingsKey.language) var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            ProgressView()
                .task {
                    await viewModel.loadData(evolutionDetail: evolutionDetail, language: language)
                }
        case .loaded:
            VStack {
                ForEach(EvolutionDetailViewModel.EvolutionDetailKey.allCases) { evolutionDetailKey in
                    if let value = viewModel.evolutionDetails[evolutionDetailKey] {
                        HStack {
                            Text(value)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}
struct EvolutionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EvolutionDetailView(evolutionDetail: EvolutionChain.example.chain.evolvesTo.first!.evolutionDetails.first!)
    }
}
