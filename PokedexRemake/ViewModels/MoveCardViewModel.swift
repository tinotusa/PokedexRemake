//
//  MoveCardViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 9/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class MoveCardViewModel: ObservableObject {
    @Published private(set) var damageClass: MoveDamageClass!
    @Published private(set) var type: `Type`!
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "MoveCardViewModel")
}

extension MoveCardViewModel {
    func loadData(move: Move) async {
        logger.debug("Loading data.")
        do {
            let id = move.damageClass.url.lastPathComponent
            let typeID = move.type.url.lastPathComponent
            
            async let damageClass = MoveDamageClass(id)
            async let type = Type(typeID)
            
            self.damageClass = try await damageClass
            self.type = try await type
            
            viewLoadingState = .loaded
            logger.debug("Successfully loaded move data.")
        } catch {
            logger.error("Failed to load data.")
            viewLoadingState = .error(error: error)
        }
    }
}
