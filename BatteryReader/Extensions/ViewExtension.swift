//
//  ViewExtension.swift
//  Battery Monitor
//
//  Created by Matt on 6/1/26.
//

import SwiftUI


extension View {
    
    func widgetText() -> some View {
        self
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(EdgeInsets(top: 5, leading: 5, bottom:  2, trailing: 5))
    }
    
    func gridRowGlassEffect() -> some View {
        self
            .labelsHidden()
            .glassEffect(.clear)
    }
    func buttonGlassEffect() -> some View {
        self
            .padding(8)
            .buttonStyle(.plain)
            .glassEffect(.clear)
    }
}

extension Grid {
    func gridStyle() -> some View {
        self
            .padding()
            .toggleStyle(.switch)
    }
}
