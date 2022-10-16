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
    @ObservedObject var itemsCategoryViewModel: ItemsCategoryViewModel
    @ObservedObject var abilitiesCategoryViewModel: AbilitiesCategoryViewModel
    @ObservedObject var locationsCategoryViewModel: LocationsCategoryViewModel
    
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
                NavigationLink(value: itemsCategoryViewModel) {
                    CategoryGridCard(title: "Items")
                }
                NavigationLink(value: abilitiesCategoryViewModel) {
                    CategoryGridCard(title: "Abilities")
                }
            }
            GridRow {
                NavigationLink(value: locationsCategoryViewModel) {
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
            moveCategoryViewModel: MoveCategoryViewModel(),
            itemsCategoryViewModel: ItemsCategoryViewModel(),
            abilitiesCategoryViewModel: AbilitiesCategoryViewModel(),
            locationsCategoryViewModel: LocationsCategoryViewModel()
        )
    }
}
