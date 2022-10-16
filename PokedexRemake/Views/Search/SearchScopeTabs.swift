//
//  SearchScopeTabs.swift
//  PokedexRemake
//
//  Created by Tino on 16/10/2022.
//

import SwiftUI

struct SearchScopeTabs: View {
    @Binding var selection: SearchScope
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(SearchScope.allCases) { searchScope in
                    Button {
                        selection = searchScope
                    } label: {
                        Text(searchScope.title)
                            .bodyStyle()
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(isSelected(searchScope) ? Color.selectedTab : Color.unselectedTab)
                            .cornerRadius(7)
                    }
                }
            }
        }
    }
    
    func isSelected(_ other: SearchScope) -> Bool {
        selection == other
    }
}
struct SearchScopeTabs_Previews: PreviewProvider {
    static var previews: some View {
        SearchScopeTabs(selection: .constant(.pokemon))
    }
}
