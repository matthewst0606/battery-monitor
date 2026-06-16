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
    
    func ListItem(arg1: String, arg2: String) -> some View {
        return HStack {
            Text(arg1)
            Spacer()
            Text(arg2)
        }
    }
    
    func createTab(title: String, tag: String, selectedStat: Binding<String>) -> some View {
        Button {
            withAnimation(.easeInOut) {
                selectedStat.wrappedValue = tag
            }
        }
        label: {
            Text(title).tabBarButtonAnimation(isSelected: selectedStat.wrappedValue == tag)
        }
        .tabBarButton(val: selectedStat.wrappedValue, isSelected: selectedStat.wrappedValue == tag)
    }
        
    
    func unscrollableListStyle() -> some View {
        self
            .listStyle(.inset)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scrollDisabled(true)
    }
    
    func tabBarButton(val: String, isSelected: Bool) -> some View {
        self
            .buttonStyle(isSelected ? .glass(.clear) : .glass(.regular))
            .buttonSizing(.flexible)
            .animation(.easeInOut, value: val)
    }
    
    func tabBarButtonAnimation(isSelected: Bool) -> some View {
        if isSelected {
            self
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 7)
                .padding(.vertical, 7)
        }
        else {
            self
                .font(.system(size: 11, weight: .regular))
                .padding(.horizontal, 3)
                .padding(.vertical, 5)
        }
        
        
        
    }
        
        
        
    func appTabStyle() -> some View {
        self
            .padding(20)
            .frame(width: 300, height: 200)
            .background(.clear)
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
