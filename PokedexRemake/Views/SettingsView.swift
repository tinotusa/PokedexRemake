//
//  SettingsView.swift
//  PokedexRemake
//
//  Created by Tino on 5/11/2022.
//

import SwiftUI
import SwiftPokeAPI

struct SettingsView: View {
    @AppStorage(SettingsKey.language.rawValue) private var languageCode = SettingsKey.defaultLanguage
    @AppStorage(SettingsKey.isDarkMode.rawValue) private var isDarkMode = SettingsKey.defaultIsDarkMode
    @AppStorage(SettingsKey.shouldCacheResults.rawValue) private var shouldCacheResults = SettingsKey.defaultCacheSetting
    
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingDeleteConfirmation = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
                    .task {
                        await viewModel.loadLanguages()
                    }
            case .loaded:
                NavigationStack {
                    ScrollView {
                        VStack {
                            Toggle("Should cache results", isOn: $shouldCacheResults)
                            Toggle("Dark mode", isOn: $isDarkMode)
                            HStack {
                                Text("Language")
                                Spacer()
                                Picker("Language", selection: $languageCode) {
                                    ForEach(viewModel.languages) { language in
                                        Text(language.selfLocalizedName())
                                            .tag(language.name)
                                    }
                                }
                            }
                            HStack {
                                Text("Cache size: \(viewModel.cacheSize())")
                                Spacer()
                                Button("Clear cache", role: .destructive) {
                                    showingDeleteConfirmation = true
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .bodyStyle()
                        .padding()
                    }
                    .navigationTitle("Settings")
                    .toolbar {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                .confirmationDialog("Clear cache", isPresented: $showingDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        viewModel.clearCache()
                    }
                } message: {
                    Text("Clear cache")
                }
            case .error(let error):
                ErrorView(text: error.localizedDescription)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
