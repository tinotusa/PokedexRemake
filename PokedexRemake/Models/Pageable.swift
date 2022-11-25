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

extension  Pageable {
    /// A Boolean value indicating whether or not there is a next page.
    var hasNextPage: Bool {
        pageInfo.hasNextPage
    }
    /// A Boolean value indicating whether or not the first page has been loaded.
    var hasLoadedFirstPage: Bool {
        pageInfo.hasLoadedFirstPage
    }
}
