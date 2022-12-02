//
//  ViewLoadingState.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation

/// The state of a view.
enum ViewLoadingState {
    case loading
    case loaded
    case error(error: Error)
}
