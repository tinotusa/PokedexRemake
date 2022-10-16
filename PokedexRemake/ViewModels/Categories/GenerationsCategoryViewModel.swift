//
//  GenerationsCategoryViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import Foundation
import SwiftPokeAPI
import os

final class GenerationsCategoryViewModel: ObservableObject, Identifiable {
    let id = UUID().uuidString
    
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    @Published private(set) var generations = Set<Generation>()
    
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "GenerationsCategoryViewModel")
}

extension GenerationsCategoryViewModel {
    func sortedGenerations() -> [Generation] {
        self.generations.sorted()
    }
    
    @MainActor
    func loadData() async {
        do {
            let resource = try await Resource<Generation>(limit: 20)
            self.generations = resource.items
            viewLoadingState = .loaded
        } catch {
            logger.error("Failed to load generations. \(error)")
            viewLoadingState = .error(error: error)
        }
    }
}

extension GenerationsCategoryViewModel: Hashable {
    static func == (lhs: GenerationsCategoryViewModel, rhs: GenerationsCategoryViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
