//
//  CategoryGrid.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct CategoryGrid: View {
    @ObservedObject var pokemonCategoryViewModel: PokemonCategoryViewModel
    @ObservedObject var moveCategoryViewModel: MoveCategoryViewModel
    
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 10) {
            GridRow {
                NavigationLink(value: pokemonCategoryViewModel) {
                    CategoryGridCard(title: "Pokemon")
                }
                NavigationLink(value: moveCategoryViewModel) {
                    CategoryGridCard(title: "Moves")
                }
            }
            GridRow {
                NavigationLink {
                    Text("Items detail")
                } label: {
                    CategoryGridCard(title: "Items")
                }
                NavigationLink {
                    Text("Abilities detail")
                } label: {
                    CategoryGridCard(title: "Abilities")
                }
            }
            GridRow {
                NavigationLink {
                    Text("Locations detail")
                } label: {
                    CategoryGridCard(title: "Locations")
                }
                NavigationLink {
                    Text("Generations detail")
                } label: {
                    CategoryGridCard(title: "Generations")
                }
            }
        }
    }
}

struct CategoryGrid_Previews: PreviewProvider {
    static var previews: some View {
        CategoryGrid(
            pokemonCategoryViewModel: PokemonCategoryViewModel(),
            moveCategoryViewModel: MoveCategoryViewModel()
        )
    }
}
