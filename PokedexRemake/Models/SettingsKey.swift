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

/// An enum that holds the
struct SettingsKey {
    static let isDarkMode = "isDarkMode"
    static let language = "language"
    static let shouldCacheResults = "shouldCacheResults"
    
    static let defaultLanguage = "en"
    static let defaultIsDarkMode = false
    static let defaultCacheSetting = true
}
