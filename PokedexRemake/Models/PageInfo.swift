//
//  PageInfo.swift
//  PokedexRemake
//
//  Created by Tino on 5/11/2022.
//

import Foundation

/// Information about a page.
struct PageInfo {
    /// The number of things per page.
    let limit: Int
    /// The current offset of page.
    var offset: Int
    /// Whether or not there is a next page.
    var hasNextPage: Bool = true
    
    /// Creates a PageInfo with the given arguments.
    init(limit: Int = 20, offset: Int = 0, hasNextPage: Bool = true) {
        self.limit = limit
        self.offset = offset
        self.hasNextPage = hasNextPage
    }
}
