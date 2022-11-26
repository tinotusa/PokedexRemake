//
//  DropdownButton.swift
//  PokedexRemake
//
//  Created by Tino on 26/11/2022.
//

import SwiftUI

struct DropdownButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(label)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.accentColor)
            }
            .contentShape(Rectangle())
            .title2Style()
            .fontWeight(.light)
        }
    }
}
struct DropdownButton_Previews: PreviewProvider {
    static var previews: some View {
        DropdownButton(label: "Hello world!") {
            // action here
        }
    }
}
