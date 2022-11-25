//
//  CategoryGrid.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct CategoryGrid: View {
    @ObservedObject var pokemonCategoryViewModel: CategoryViewModel<Pokemon>
    @ObservedObject var moveCategoryViewModel: CategoryViewModel<Move>
    @ObservedObject var itemsCategoryViewModel: CategoryViewModel<Item>
    @ObservedObject var abilitiesCategoryViewModel: CategoryViewModel<Ability>
    @ObservedObject var locationsCategoryViewModel: CategoryViewModel<Location>
    @ObservedObject var generationsCategoryViewModel: CategoryViewModel<Generation>
    
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 10) {
            GridRow {
                NavigationLink {
                    CategoryView(viewModel: pokemonCategoryViewModel, title: "Pokemon") { pokemon in
                        PokemonResultRow(pokemon: pokemon)
                    }
                } label: {
                    CategoryGridCard(title: "Pokemon")
                }
                NavigationLink {
                    CategoryView(viewModel: moveCategoryViewModel, title: "Moves") { move in
                        MoveCard(move: move)
                    }
                } label: {
                    CategoryGridCard(title: "Moves")
                }
            }
            GridRow {
                NavigationLink {
                    CategoryView(viewModel: itemsCategoryViewModel, title: "Items") { item in
                        ItemCard(item: item)
                    }
                } label: {
                    CategoryGridCard(title: "Items")
                }
                NavigationLink {
                    CategoryView(viewModel: abilitiesCategoryViewModel, title: "Abilities") { ability in
                        AbilityCard(ability: ability)
                    }
                } label: {
                    CategoryGridCard(title: "Abilities")
                }
            }
            GridRow {
                NavigationLink {
                    CategoryView(viewModel: locationsCategoryViewModel, title: "Locations") { location in
                        LocationCard(location: location)
                    }
                } label: {
                    CategoryGridCard(title: "Locations")
                }
                NavigationLink {
                    CategoryView(viewModel: generationsCategoryViewModel, title: "Generations") { generation in
                        GenerationCard(generation: generation)
                    }
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
            pokemonCategoryViewModel: CategoryViewModel<Pokemon>(),
            moveCategoryViewModel: CategoryViewModel<Move>(),
            itemsCategoryViewModel: CategoryViewModel<Item>(),
            abilitiesCategoryViewModel: CategoryViewModel<Ability>(),
            locationsCategoryViewModel: CategoryViewModel<Location>(),
            generationsCategoryViewModel: CategoryViewModel<Generation>()
        )
    }
}
