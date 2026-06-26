//
//  VStackExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//
import SwiftUI

extension VStack {
    func appTabStyle() -> some View {
        self
            .frame(minWidth: 300, maxWidth: 500)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    func windowTabStyle(_ title: String) -> some View {
        self
            .frame(minWidth: 500, maxHeight: .infinity, alignment: .top)
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .navigationTitle(Text(title))
    }
}

extension HStack {
    func standardPadding() -> some View {
        self
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
    }
}
