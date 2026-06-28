//
//  ButtonExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//

import SwiftUI

extension Button {
    func tabBarButton(val: String, isSelected: Bool) -> some View {
        self
            .buttonStyle(.glass(isSelected ? .clear : .regular))
            .buttonSizing(.flexible)
            .background(
                isSelected ? .blue.opacity(0.5) : .clear,
                in: .capsule
            )
        
            .buttonBorderShape(.roundedRectangle(radius: 10))
            .animation(.easeInOut, value: isSelected)
    }
}

struct HoverAnimationModifier: ViewModifier {
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovering ? 1.08 : 1.0)
            .animation(.bouncy, value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}


