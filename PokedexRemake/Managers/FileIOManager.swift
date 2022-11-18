//
//  FileIOManager.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import os

/// A manager for file input and output.
struct FileIOManager {
    /// The file manager used for saving and loading.
    var fileManager = FileManager.default
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "FileIOManager")
    
    /// Writes a value to the given file name.
    /// - Parameters:
    ///   - value: The value to write to disk.
    ///   - filename: The name of the file.
    ///   - encoder: An encoder used to encode the value.
    func write<T: Codable>(_ value: T, filename: String, encoder: JSONEncoder = .init()) throws {
        logger.debug("Writing file \(filename) to disk.")
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appending(path: filename)
        
        let data = try encoder.encode(value)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        logger.debug("Successfully wrote file \(filename) to disk.")
    }
    
    /// Returns a value from a file on disk.
    /// - Parameters:
    ///   - type: The type of the value.
    ///   - filename: The file name of the value on disk.
    ///   - decoder: A decoder to decode the value.
    /// - Returns: A value of the given type.
    func load<T: Codable>(_ type: T.Type, filename: String, decoder: JSONDecoder = .init()) throws -> T {
        logger.debug("Loading file \(filename) from disk.")
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appending(path: filename)
        let data = try Data(contentsOf: fileURL)
        
        let decodedData = try decoder.decode(type, from: data)
        logger.debug("Successfully loaded file \(filename) from disk.")
        return decodedData
    }
    
    /// Deletes a file with the given name from the documents directory.
    /// - Parameter filename: The name of the file to delete.
    func delete(_ filename: String) throws {
        let documentsURL = fileManager.documentsURL()
        let fileURL = documentsURL.appending(path: filename)
        try fileManager.removeItem(at: fileURL)
    }
}
