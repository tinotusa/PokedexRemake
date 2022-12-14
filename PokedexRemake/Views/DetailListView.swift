//
//  DetailListView.swift
//  PokedexRemake
//
//  Created by Tino on 21/10/2022.
//

import SwiftUI

struct DetailListView<Content: View>: View {
    let title: String
    let description: LocalizedStringKey
    let content: () -> Content
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(description)
                    Divider()
                    content()
                }
                .padding(.horizontal)
            }
            .navigationTitle(title)
            .bodyStyle()
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .background(Color.secondaryBackground)
            .toolbar {
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.accentColor)
            }
        }
    }
}

struct DetailListView_Previews: PreviewProvider {
    static var previews: some View {
        DetailListView(
            title: "some title",
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
