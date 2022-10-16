//
//  SettingsKey.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation
import SwiftUI
import SwiftPokeAPI
import os

enum SettingsKey: String {
    case isDarkMode
    case language
    case shouldCacheResults
    
    static let defaultLanguage = "en"
    static let defaultColorScheme = "dark"
    static let defaultCacheSetting = true
}
