//
//  MachineCard.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MachineCard: View {
    private let machine: Machine
    @StateObject private var viewModel: MachineCardViewModel
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    
    init(machine: Machine) {
        self.machine = machine
        _viewModel = StateObject(wrappedValue: MachineCardViewModel(machine: machine))
    }
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPlaceholder
                .onAppear {
                    Task {
                        await viewModel.loadData(languageCode: language)
                    }
                }
        case .loaded:
            if let item = viewModel.item {
                HStack {
                    PokemonImage(url: item.sprites.default, imageSize: 80)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(viewModel.itemName)
                            .subtitleStyle()
                        Text(viewModel.moveName)
                        
                        ViewThatFits(in: .horizontal) {
                            HStack {
                                versionsList()
                            }
                            VStack(alignment: .leading, spacing: 0) {
                                versionsList(showDivider: false)
                            }
                        }
                        .foregroundColor(.gray)
                    }
                }
                .subtitle2Style()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadData(languageCode: language)
                }
            }
        }
    }
}

extension MachineCard {
    var loadingPlaceholder: some View {
        HStack {
            Image("bulbasaur")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Item name")
                    .subtitleStyle()
                Text("Move name")
                
                ForEach(0 ..< 2) { index in
                    Text("Version\(index)")
                }
                .foregroundColor(.gray)
            }
        }
        .subtitle2Style()
        .frame(maxWidth: .infinity, alignment: .leading)
        .redacted(reason: .placeholder)
    }
    
    @ViewBuilder
    func versionsList(showDivider: Bool = true) -> some View {
        ForEach(viewModel.versions) { version in
            Text(version.localizedName(languageCode: language))
            if showDivider && version != viewModel.versions.last {
                Divider()
            }
        }
    }
}

struct MachineCard_Previews: PreviewProvider {
    static var previews: some View {
        MachineCard(machine: .example)
    }
}
