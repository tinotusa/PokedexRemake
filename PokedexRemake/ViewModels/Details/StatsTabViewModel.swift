//
//  StatsTabViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 7/10/2022.
//

import Foundation
import SwiftPokeAPI

final class StatsTabViewModel: ObservableObject {
    @Published private(set) var stats = Set<Stat>()
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
}
