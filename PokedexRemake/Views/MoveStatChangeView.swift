//
//  MoveStatChangeView.swift
//  PokedexRemake
//
//  Created by Tino on 22/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct MoveStatChangeView: View {
    let statChange: MoveStatChange
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct MoveStatChangeView_Previews: PreviewProvider {
    static var previews: some View {
        MoveStatChangeView(statChange: Move.flashExample.statChanges.first!)
    }
}
