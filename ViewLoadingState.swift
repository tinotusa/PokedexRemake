//
//  ViewLoadingState.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import Foundation

enum ViewLoadingState {
    case loading
    case loaded
    case error(error: Error)
}
