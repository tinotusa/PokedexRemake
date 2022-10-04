//
//  TextStyles.swift
//  PokedexRemake
//
//  Created by Tino on 3/10/2022.
//

import SwiftUI

struct TextStyles: View {
    var body: some View {
        VStack {
            Text("Header text style")
                .headerTextStyle()
            Text("Category Title style")
                .categoryTitleStyle()
            Text("Title style")
                .titleStyle()
            Text("Body style")
                .bodyStyle()
            Text("Body style 2")
                .bodyStyle2()
        }
    }
}

// MARK: - Styles
struct HeaderTextStyle: ViewModifier {
    @ScaledMetric private var size = 40
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.headerText)
            .font(.system(size: size, weight: .regular))
    }
}

struct TitleStyle: ViewModifier {
    @ScaledMetric private var size = 30
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.text)
            .font(.system(size: size, weight: .regular))
    }
}


struct CategoryTitleStyle: ViewModifier {
    @ScaledMetric private var size = 30
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.categoryTitle)
            .font(.system(size: size, weight: .regular))
    }
}

struct BodyStyle2: ViewModifier {
    @ScaledMetric private var size = 12
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.text)
            .font(.system(size: size, weight: .regular))
    }
}

struct BodyStyle: ViewModifier {
    @ScaledMetric private var size = 20
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.text)
            .font(.system(size: size, weight: .regular))
    }
}


// MARK: - View extensions
extension View {
    func headerTextStyle() -> some View {
       modifier(HeaderTextStyle())
    }
    
    func titleStyle() -> some View {
        modifier(TitleStyle())
    }
    
    func categoryTitleStyle() -> some View {
        modifier(CategoryTitleStyle())
    }
    
    func bodyStyle() -> some View {
        modifier(BodyStyle())
    }
    
    func bodyStyle2() -> some View {
        modifier(BodyStyle2())
    }
}
// MARK: - Preview
struct TextStyles_Previews: PreviewProvider {
    static var previews: some View {
        TextStyles()
    }
}
