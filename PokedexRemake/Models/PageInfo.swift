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
    /// A Boolean value indicating whether or not the first page has been loaded.
    var hasLoadedFirstPage = false
    
    /// Creates a PageInfo with the given arguments.
    init(limit: Int = 20, offset: Int = 0) {
        self.limit = limit
        self.offset = offset
    }
    
    /// Adds the limit amount to the offset.
    mutating func updateOffset() {
        self.offset += self.limit
    }
}
