//
//  EvolutionsTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import Foundation

final class EvolutionsTabViewModel: ObservableObject {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
}
