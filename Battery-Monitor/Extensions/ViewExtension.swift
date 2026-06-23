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
    

        


}

// Lists
extension View {
    func unscrollableListStyle() -> some View {
        self
            .listStyle(.inset)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scrollDisabled(true)
    }
    
    func ListItem(arg1: String, arg2: String, arg3: Color) -> some View {
        return HStack {
            Text(arg1)
            Spacer()
            Text(arg2)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(arg3)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
    }
}

//tabs
extension View {
    func appTabStyle() -> some View {
        self
            .frame(minWidth: 300, maxWidth: 500)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    func windowTabStyle(title: String) -> some View {
        self
            .frame(minWidth: 500, maxHeight: .infinity, alignment: .top)
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .navigationTitle(Text(title))
    }
    
    func createTab(title: String, tag: String, selectedStat: Binding<String>) -> some View {
        Button {
            withAnimation(.easeInOut) {
                selectedStat.wrappedValue = tag
            }
        }
        label: {
            Text(title).tabBarButtonAnimation(
                isSelected: selectedStat.wrappedValue == tag
            )
        }
        .tabBarButton(
            val: selectedStat.wrappedValue,
            isSelected: selectedStat.wrappedValue == tag
        )
    }
}




// Buttons
extension View {
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
    
    func tabBarButtonAnimation(isSelected: Bool) -> some View {
        if isSelected {
            self
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 0)
                .padding(.vertical, 5)
        }
        else {
            self
                .font(.system(size: 11, weight: .regular))
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
        }
    }
}

// settings
extension View {
    func settingsButton(_ buttonLabel: String, action: @escaping () -> Void) -> some View {
        Button { action() }
        label: {
                Text(buttonLabel)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 5)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
        
    }
}
