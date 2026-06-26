//
//  ListExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//
import SwiftUI

extension List {
    func unscrollableListStyle() -> some View {
        self
            .listStyle(.inset)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scrollDisabled(true)
    }
    func scrollableListStyle() -> some View {
        self
            .listStyle(.inset)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
