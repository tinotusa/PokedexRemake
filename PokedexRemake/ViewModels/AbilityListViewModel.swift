//
//  AbilityListViewModel.swift
//  PokedexRemake
//
//  Created by Tino on 3/11/2022.
//

import Foundation
import SwiftPokeAPI
import os

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

#warning("can this be cleaned up")
final class AbilityListViewModel: ObservableObject, Pageable {
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    
    @Published private(set) var values = [Ability]()
    @Published private(set) var pageInfo = PageInfo(limit: 20)
    @Published private(set) var pageState = PaginationState.loadingFirstPage
    
    private var urls = [URL]()
    private let logger = Logger(subsystem: "com.tinotusa.PokedexRemake", category: "AbilityListViewModel")
}

extension AbilityListViewModel {
    @MainActor
    func setUp(urls: [URL]) {
        self.urls = urls
    }
    
    var hasNextPage: Bool {
        pageInfo.hasNextPage
    }
    
    @MainActor
    func loadPage() async {
        if !pageInfo.hasNextPage {
            return
        }
        
        switch pageState {
        case .loadingFirstPage:
            do {
                let (abilities, pageInfo) = try await loadPage(pageInfo: pageInfo)
                self.values.append(contentsOf: abilities)
                self.pageInfo = pageInfo
                viewLoadingState = .loaded
            } catch {
                viewLoadingState = .error(error: error)
                pageState = .error(error: error)
            }
        case .loadingNextPage:
            return
        default:
            do {
                let (abilities, pageInfo) = try await loadPage(pageInfo: pageInfo)
                self.values.append(contentsOf: abilities)
                self.pageInfo = pageInfo
            } catch {
                pageState = .error(error: error)
            }
        }
    }
    
    @MainActor
    func loadPage(pageInfo: PageInfo) async throws -> (items: [Ability], pageInfo: PageInfo) {
        pageState = .loadingNextPage
        defer {
            pageState = .loaded
        }
        return try await withThrowingTaskGroup(of: Ability.self) { group in
            for (i, url) in self.urls.enumerated() where i >= pageInfo.offset && i < pageInfo.offset + pageInfo.limit {
                group.addTask {
                    return try await Ability(url)
                }
            }
            var abilities = [Ability]()
            for try await ability in group {
                abilities.append(ability)
            }
            let pageInfo = PageInfo(
                offset: self.pageInfo.offset + pageInfo.limit,
                hasNextPage: abilities.count == pageInfo.limit
            )
            return (abilities, pageInfo)
        }
    }
}
