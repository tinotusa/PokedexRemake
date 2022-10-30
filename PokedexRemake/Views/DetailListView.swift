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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button("Close") {
                dismiss()
            }
            .foregroundColor(.accentColor)
            .padding([.horizontal, .top])
        
            
            ScrollView {
                VStack(alignment: .leading) {
                    HeaderBar(title: title, id: id)
                    Text(description)
                    Divider()
                    content()
                }
                .padding(.horizontal)
            }
        }
        .bodyStyle()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
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
        }
    }
}
