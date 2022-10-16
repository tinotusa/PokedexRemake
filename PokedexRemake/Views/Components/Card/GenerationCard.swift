//
//  GenerationCard.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct GenerationCard: View {
    let generation: Generation
    @StateObject private var viewModel = GenerationCardViewModel()
    @AppStorage(SettingsKey.language.rawValue) private var language = SettingsKey.defaultLanguage
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            loadingPlaceholder
                .task {
                    await viewModel.loadData(generation: generation)
                }
        case .loaded:
            NavigationLink(value: generation) {
                VStack {
                    Text(generation.localizedName(for: language))
                        .title2Style()
                        .fontWeight(.light)
                    Text(viewModel.localizedRegionName(languageCode: language))
                        .foregroundColor(.gray)
                        .subtitleStyle()
                    ViewThatFits(in: .horizontal) {
                        HStack {
                            versionsList
                        }
                        .foregroundColor(.gray)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                versionsList
                            }
                            .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .cornerRadius(Constants.cornerRadius)
                .shadow(
                    color: Constants.shadowColour,
                    radius: Constants.shadowRadius,
                    x: Constants.shadowX,
                    y: Constants.shadowY
                )
            .bodyStyle()
            }
        case .error(let error):
            ErrorView(text: error.localizedDescription)
        }
        
    }
}

private extension GenerationCard {
    enum Constants {
        static let cornerRadius = 8.0
        
        static let shadowColour = Color.black.opacity(0.3)
        static let shadowRadius = 3.0
        static let shadowX = 0.0
        static let shadowY = 2.0
        
        static let dividerHeight = 20.0
    }
    var versionsList: some View {
        ForEach(viewModel.sortedVersions()) { version in
            Text(version.localizedName(for: language))
            Divider()
        }
    }
    
    var loadingPlaceholder: some View {
        VStack {
            Text("Generation")
                .title2Style()
                .fontWeight(.light)
            Text("Region")
                .foregroundColor(.gray)
                .subtitleStyle()
            HStack {
                ForEach(0..<2) { id in
                    Text("Game\(id)")
                }
            }
            .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white)
        .cornerRadius(Constants.cornerRadius)
        .shadow(
            color: Constants.shadowColour,
            radius: Constants.shadowRadius,
            x: Constants.shadowX,
            y: Constants.shadowY
        )
        .redacted(reason: .placeholder)
    }
}

struct GenerationCard_Previews: PreviewProvider {
    static var previews: some View {
        GenerationCard(generation: .example)
    }
}
