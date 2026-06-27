//
//  ButtonExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//

import SwiftUI

extension Button {
    func tabBarButton(val: String, isSelected: Bool) -> some View {
        if isSelected {
            self
                .buttonStyle(.glass(.clear))
                .buttonSizing(.flexible)
                .background(.blue.opacity(0.5), in: .capsule)
                .buttonBorderShape(.roundedRectangle)
                .animation(.easeInOut, value: val)
        }
        else {
            self
                .buttonStyle(.glass(.regular))
                .buttonSizing(.flexible)
                .background(.clear, in: .capsule)
                .buttonBorderShape(.roundedRectangle)
                .animation(.easeInOut, value: val)
        }
    }
    
    

}

struct HoverAnimationModifier: ViewModifier {
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovering ? 1.06 : 1.0)
            .animation(.bouncy, value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}
