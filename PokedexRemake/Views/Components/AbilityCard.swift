//
//  AbilityCard.swift
//  PokedexRemake
//
//  Created by Tino on 10/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct AbilityCard: View {
    let ability: Ability
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    
    var body: some View {
        VStack {
            HStack {
                Text(ability.localizedName(for: language))
                Spacer()
                Text(Globals.formattedID(ability.id))
                    .foregroundColor(.gray)
            }
            .subtitleStyle()
//                    Text(viewModel.generation.local)
        }
    }
}

struct AbilityCard_Previews: PreviewProvider {
    static var previews: some View {
        AbilityCard(ability: .example)
    }
}
