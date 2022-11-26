//
//  MoveStatChangeView.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MoveStatChangeView: View {
    private let moveStatChange: MoveStatChange
    @StateObject private var viewModel: MoveStatChangeViewModel
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    
    init(moveStatChange: MoveStatChange) {
        self.moveStatChange = moveStatChange
        _viewModel = StateObject(wrappedValue: MoveStatChangeViewModel(moveStatChange: moveStatChange))
    }
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPlaceholder
                .task {
                    await viewModel.loadData(languageCode: language)
                }
        case .loaded:
            Grid(alignment: .leading) {
                GridRow {
                    Text(viewModel.statName)
                        .foregroundColor(.gray)
                    Text(formatNumber(moveStatChange.change))
                }
            }
            .bodyStyle()
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadData(languageCode: language)
                }
            }
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
        MoveStatChangeView(moveStatChange: Move.flashExample.statChanges.first!)
    }
}
