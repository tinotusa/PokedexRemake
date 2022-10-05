//
//  TypeTag.swift
//  PokedexRemake
//
//  Created by Tino on 5/10/2022.
//

import SwiftUI
import SwiftPokeAPI

struct TypeTag: View {
    let type: `Type`
    @AppStorage(SettingKey.language.rawValue) private var language = "en"
    
    var body: some View {
        Text(type.localizedName(for: language))
            .lineLimit(1)
            .padding(.horizontal)
            .background(Color(type.name))
            .cornerRadius(5)
            .bodyStyle2()
    }
}

struct TypeTag_Previews: PreviewProvider {
    static var previews: some View {
        TypeTag(type: .grassExample)
    }
}
