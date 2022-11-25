//
//  Pageable.swift
//  PokedexRemake
//
//  Created by Tino on 5/11/2022.
//

import Foundation
import SwiftPokeAPI

/// A type that can be paginated.
protocol Pageable {
    /// The current pages information.
    var pageInfo: PageInfo { get }
    
    /// Fetches some page info.
    func loadPage() async
}

// TODO: Remove me
/// The value that represents the state of the pagination.
enum PaginationState {
    case loadingFirstPage
    case loaded
    case loadingNextPage
    case error(error: Error)
}
