//
//  SettingsViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 5/11/2022.
//

import Foundation
import SwiftPokeAPI
import os

extension Language {
    /// The name of the language in its own language.
    ///
    /// e.g ko -> 한국어
    /// ja -> 日本語
    ///
    /// - returns: The localised name for the language.
    func selfLocalizedName() -> String {
        var name: Name? = self.names.first { $0.language.name == self.name }
        
        // fallback if a own language name wasn't found
        if name == nil {
            name = self.names.first { $0.language.name == "en" }
        }
        if let name {
            return name.name
        }
        
        // the default name for the Language
        return self.name
    }
}

final class SettingsViewModel: ObservableObject {
    @Published private(set) var languages = [Language]()
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    private static let saveFilename = "languagesSaveFile"
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "SettingsViewModel")
    
    func cacheSize() -> String {
        do {
            let size = try PokeAPI.shared.cacheSize()
            return size.formatted(.byteCount(style: .file))
        } catch {
            logger.error("Failed to get cache size. \(error)")
        }
        return 0.formatted(.byteCount(style: .file))
    }
    
    func clearCache() {
        PokeAPI.shared.clearCache()
    }
    
    @MainActor
    func loadLanguages() async {
        logger.debug("Loading languages.")
        let fileManager = FileManager.default
        let documentsURL = fileManager.documentsURL()
        let saveFileURL =  documentsURL.appendingPathExtension(Self.saveFilename)
        
        if let data = try? Data(contentsOf: saveFileURL) {
            do {
                let languages = try JSONDecoder().decode([Language].self, from: data)
                self.languages = languages
                logger.debug("Successfully loaded languages from disk.")
                viewLoadingState = .loaded
                return
            } catch {
                logger.error("Failed to decode languages from disk. \(error)")
            }
        }
        
        do {
            let resource = try await Resource<Language>()
            self.languages = resource.items.sorted()
            logger.debug("Successfully downloaded languages from pokeapi.")
            let data = try JSONEncoder().encode(self.languages)
            try data.write(to: saveFileURL, options: [.atomic, .completeFileProtection])
            logger.debug("Successfully saved languages to disk.")
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to get languages. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}
