//
//  DetailListView.swift
//  PokedexRemake
//
//  Created by Tino on 21/10/2022.
//

import SwiftUI

struct DetailListView<Content: View>: View {
    let title: String
    let id: Int
    let description: LocalizedStringKey
    let content: () -> Content
    var onDismiss: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .trailing) {
            if let onDismiss {
                Button("Close") {
                    onDismiss()
                }
                .foregroundColor(.accentColor)
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    HeaderBar(title: title, id: id)
                    Text(description)
                    Divider()
                    content()
                }
            }
        }
        .padding()
        .bodyStyle()
    }
}

struct DetailListView_Previews: PreviewProvider {
    static var previews: some View {
        DetailListView(
            title: "some title",
            id: 999,
            description: "some description goes here"
        ) {
            VStack(alignment: .leading) {
                ForEach(0 ..< 10) { index in
                    Text("This is row: \(index + 1)")
                }
            }
        } onDismiss: {
            
        }
    }
}
