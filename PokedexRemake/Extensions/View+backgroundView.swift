//
//  View+backgroundView.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct BackgroundView: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .frame(width: proxy.size.width)
                .background(alignment: .top) {
                        Circle()
                            .foregroundColor(.backgroundCircle)
                            .frame(width: proxy.size.width * 1.5)
                            .offset(y: -proxy.size.height * 0.5)
                    }
                .background(alignment: .bottomLeading) {
                    Circle()
                        .foregroundColor(.backgroundCircle)
                        .offset(
                            x: -proxy.size.width * 0.4,
                            y: proxy.size.height * 0.3
                        )
                }
        }
    }
}

extension View {
    func backgroundView() -> some View {
        modifier(BackgroundView())
    }
}
