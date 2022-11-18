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
    associatedtype Value: Codable & SearchableByURL
    
    /// The values of the page.
    var values: [Value] { get }
    
    /// The current pages information.
    var pageInfo: PageInfo { get }
    
    /// Fetches values based of the given page info.
    /// - Parameter pageInfo: The current page info.
    /// - Returns: A tuple of items and the information about the next page.
    func loadPage(pageInfo: PageInfo) async throws -> (items: [Value], pageInfo: PageInfo)
}

/// The value that represents the state of the pagination.
enum PaginationState {
    case loadingFirstPage
    case loaded
    case loadingNextPage
    case error(error: Error)
}
