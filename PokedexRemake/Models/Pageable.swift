//
//  Pageable.swift
//  PokedexRemake
//
//  Created by Tino on 5/11/2022.
//

import Foundation
import SwiftPokeAPI

// TODO: Update me
/// A type that can be paginated.
protocol Pageable {
    associatedtype Value: Codable & SearchableByURL
    
    /// The current pages information.
    var pageInfo: PageInfo { get }
    
    /// The state of the page.
    var pageState: PaginationState { get set }
    
    /// Fetches values based of the given page info.
    /// - Parameter pageInfo: The current page info.
    /// - Returns: A tuple of items and the information about the next page.
    func loadPage(pageInfo: PageInfo) async throws -> (items: [Value], pageInfo: PageInfo)
}

// TODO: Remove me
/// The value that represents the state of the pagination.
enum PaginationState {
    case loadingFirstPage
    case loaded
    case loadingNextPage
    case error(error: Error)
}
