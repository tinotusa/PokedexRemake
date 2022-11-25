//
//  GenerationCard.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct GenerationCard: View {
    private let generation: Generation
    @StateObject private var viewModel: GenerationCardViewModel
    @AppStorage(SettingsKey.language) private var language = SettingsKey.defaultLanguage
    
    init(generation: Generation) {
        self.generation = generation
        _viewModel = StateObject(wrappedValue: GenerationCardViewModel(generation: generation))
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
            NavigationLink {
                GenerationDetail(generation: generation)
            } label: {
                VStack {
                    Text(viewModel.generationName)
                        .title2Style()
                        .fontWeight(.light)
                    Text(viewModel.regionName)
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
                .background(Color.secondaryBackground)
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
            ErrorView(text: error.localizedDescription) {
                Task {
                    await viewModel.loadData(languageCode: language)
                }
            }
        }
        
    }
}

// MARK: - Subviews
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
        ForEach(viewModel.versions) { version in
            Text(version.localizedName(languageCode: language))
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
        .background(Color.secondaryBackground)
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
