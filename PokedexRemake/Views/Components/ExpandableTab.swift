//
//  ExpandableTab.swift
//  PokedexRemake
//
//  Created by Tino on 6/10/2022.
//

import SwiftUI

struct ExpandableTab<Content: View>: View {
    private let title: LocalizedStringKey
    private let content: () -> Content
    private let isSubheader: Bool
    
    @State private var isExpanded = false
    
    init(title: LocalizedStringKey, isSubheader: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
        self.isSubheader = isSubheader
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                VStack(spacing: 0) {
                    header
                    if isExpanded {
                        Divider()
                    }
                }
            }
            if isExpanded {
                content()
            }
        }
    }
}

private extension ExpandableTab {
    var icon: some View {
        Image(systemName: "chevron.down")
            .rotationEffect(isExpanded ? .degrees(180) : .degrees(0))
            .foregroundColor(.accentColor)
    }
    
    @ViewBuilder
    var header: some View {
        if isSubheader {
            HStack {
                Text(title)
                Spacer()
                icon
            }
            .subtitle2Style()
            .fontWeight(.light)
        } else {
            HStack {
                Text(title)
                Spacer()
                icon
            }
            .title2Style()
            .fontWeight(.light)
        }
    }
}

struct ExpandableTab_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableTab(title: "testing") {
            VStack {
                Text("This is the expanded detail")
            }
        }
    }
}
