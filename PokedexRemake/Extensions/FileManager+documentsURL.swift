//
//  FileManager+documentsURL.swift
//  PokedexRemake
//
//  Created by Tino on 18/10/2022.
//

import Foundation

extension FileManager {
    /// Gets the URL for the users documents directory.
    /// - returns: A URL for the users documents directory.
    func documentsURL() -> URL {
        self.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
