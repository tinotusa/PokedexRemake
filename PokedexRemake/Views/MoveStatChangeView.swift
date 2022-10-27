//
//  MoveStatChangeView.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MoveStatChangeView: View {
    let statChange: MoveStatChange
    @StateObject private var viewModel = MoveStatChangeViewModel()
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPlaceholder
                .task {
                    await viewModel.loadData(statChange: statChange)
                }
        case .loaded:
            if let stat = viewModel.stat {
                Grid(alignment: .leading) {
                    GridRow {
                        Text(stat.localizedName(languageCode: language))
                            .foregroundColor(.gray)
                        Text(formatNumber(statChange.change))
                    }
                }
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
    }
}

private extension MoveStatChangeView {
    var loadingPlaceholder: some View {
        ProgressView()
    }
    
    func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.positivePrefix = "+"
        if let formattedNumber = formatter.string(from: NSNumber(value: number)) {
            return formattedNumber
        }
        return "\(number)"
        
    }
}

struct MoveStatChangeView_Previews: PreviewProvider {
    static var previews: some View {
        MoveStatChangeView(statChange: Move.flashExample.statChanges.first!)
    }
}
