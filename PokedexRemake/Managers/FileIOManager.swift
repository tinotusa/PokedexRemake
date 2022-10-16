//
//  FileIOManager.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import os

struct FileIOManager {
    var fileManager = FileManager.default
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "FileIOManager")
    
    func write<T: Codable>(_ value: T, documentName: String, encoder: JSONEncoder = .init()) throws {
        logger.debug("Writing file \(documentName) to disk.")
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appending(path: documentName)
        
        let data = try encoder.encode(value)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        logger.debug("Successfully wrote file \(documentName) to disk.")
    }
    
    func load<T: Codable>(_ type: T.Type, documentName: String, decoder: JSONDecoder = .init()) throws -> T {
        logger.debug("Loading file \(documentName) from disk.")
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appending(path: documentName)
        let data = try Data(contentsOf: fileURL)
        
        let decodedData = try decoder.decode(type, from: data)
        logger.debug("Successfully loaded file \(documentName) from disk.")
        return decodedData
    }
}
