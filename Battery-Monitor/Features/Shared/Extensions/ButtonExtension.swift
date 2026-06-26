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
