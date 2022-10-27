//
//  NameLocalizable.swift
//  PokedexRemake
//
//  Created by Tino on 27/10/2022.
//

import Foundation
import SwiftPokeAPI

protocol NameLocalizable {
    var name: String { get }
    var names: [Name] { get }
}

extension NameLocalizable {
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
