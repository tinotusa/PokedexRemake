//
//  CategoryGrid.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct CategoryGrid: View {
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 10) {
            GridRow {
                NavigationLink {
                    Text("Pokemon detail")
                } label: {
                    CategoryGridCard(title: "Pokemon")
                }
                NavigationLink {
                    Text("Moves detail")
                } label: {
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
        CategoryGrid()
    }
}
