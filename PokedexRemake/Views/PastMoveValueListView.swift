//
//  PastMoveValueListView.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct PastMoveValueListView: View {
    let pastValue: PastMoveStatValues
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(pastValue.versionGroup.name!)
                .titleStyle()
            Grid {
                
            }
        }
    }
}

struct PastMoveValueListView_Previews: PreviewProvider {
    static var previews: some View {
        PastMoveValueListView(pastValue: Move.flashExample.pastValues.first!)
    }
}
