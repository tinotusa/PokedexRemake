//
//  NameLocalizable.swift
//  PokedexRemake
//
//  Created by Tino on 27/10/2022.
//

import Foundation
import SwiftPokeAPI

/// A type that can be localized by name.
protocol NameLocalizable {
    var name: String { get }
    var names: [Name] { get }
}

extension NameLocalizable {
    /// All of the language codes for the names.
    /// - returns: An array of all of the language codes the type has.
    func namesLangaugeCodes() -> [String] {
        self.names.compactMap { $0.language.name }
    }
    
    /// The localised name for the object.
    /// - parameter languageCode: The language code to localise with.
    /// - returns: The localised name if a matching localisation was found or the default name.
    func localizedName(languageCode: String) -> String {
        var name: Name?
        // try to find requested language
        name = self.names.first { name in
            name.language.name == languageCode
        }
        
        // try to fallback to device language
        if name == nil {
            let availableLanguages = self.names.compactMap { $0.language.name }
            let deviceLanguageCode = Bundle.preferredLocalizations(from: availableLanguages, forPreferences: nil).first!
            name = self.names.first { $0.language.name == deviceLanguageCode }
        }
        
        // if all else fails fallback to english
        if name == nil {
            name = self.names.first { $0.language.name == "en" }
        }
        
        if let name {
            return name.name
        }
        
        return self.name
    }
}
