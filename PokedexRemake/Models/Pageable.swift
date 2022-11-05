//
//  Pageable.swift
//  PokedexRemake
//
//  Created by Tino on 5/11/2022.
//

import Foundation
import SwiftPokeAPI

protocol Pageable {
    associatedtype Value: Codable & SearchableByURL
    var values: [Value] { get }
    var pageInfo: PageInfo { get }
    func loadPage(pageInfo: PageInfo) async throws -> (items: [Value], pageInfo: PageInfo)
}

enum PaginationState {
    case loadingFirstPage
    case loaded
    case loadingNextPage
    case error(error: Error)
}
