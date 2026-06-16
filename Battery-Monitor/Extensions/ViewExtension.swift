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
            .padding(EdgeInsets(top: 5, leading: 5, bottom:  2, trailing: 5))
    }
    
    func ListText() -> some View {
        self
        .font(.system(size: 11, weight: .regular))
        .padding(.vertical,2)
        .padding(.horizontal,5)
    }
    
    
    func unscrollableListStyle() -> some View {
        self
        .listStyle(.inset)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .scrollDisabled(true)
    }
    
    func tabBarButton(val: String) -> some View {
        self
            .buttonStyle(.glass(.clear))
            .buttonSizing(.flexible)
            .animation(.easeInOut, value: val)
    }
    
    func tabBarButtonAnimation(isSelected: Bool) -> some View {
        self
            .padding(.horizontal, isSelected ? 10 : 5)
            .padding(.vertical, isSelected ? 10 : 5)
    }
    
    func appTabStyle() -> some View {
        self
            .padding(20)
            .frame(width: 300, height: 200)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    func getGlassEffect() -> some View
        { self.glassEffect(.clear) }
    func buttonGlassEffect() -> some View
        { self.padding(8).buttonStyle(.plain).glassEffect() }
}

extension Toggle {
    func getToggleStyle() -> some View
        { self.padding().toggleStyle(.switch) }
}
