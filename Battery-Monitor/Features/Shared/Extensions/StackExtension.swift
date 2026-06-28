//
//  VStackExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//
import SwiftUI

extension VStack {
    // a small panel style
    func smallPanelStyle() -> some View {
        self
            .frame(minWidth: 300, maxWidth: 500)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    // window panel style
    func windowPanelStyle(_ title: String) -> some View {
        self
            .frame(minWidth: 500, maxHeight: .infinity, alignment: .top)
            .padding(20)
            .background(.bar)
    }
}

extension HStack {
    func standardPadding() -> some View {
        self
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
    }
}
