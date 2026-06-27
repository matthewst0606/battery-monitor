//
//  ViewExtension.swift
//  Battery Monitor
//
//  Created by Matt on 6/1/26.
//
import SwiftUI

extension View {
    func ListItem(
        _ title: String,
        value: String,
        color: Color,
    ) -> some View {
        return HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
        }
        .standardPadding()
    }
    

    func loading() -> some View {
        HStack(alignment: .center) {
            Text("Loading...").standard()
        }.frame(maxWidth: .infinity)
    }
    
    func createTab(
        _ title: String,
        tag: String,
        _ selectedStat: Binding<String>
    ) -> some View {
        Button {
            withAnimation(.easeInOut) {
                selectedStat.wrappedValue = tag
            }
        }
        label: {
            Text(title).textAnimation(
                isSelected: selectedStat.wrappedValue == tag
            )
        }
        .tabBarButton(
            val: selectedStat.wrappedValue,
            isSelected: selectedStat.wrappedValue == tag
        )
        .hoverAnimation()

    }

    
    func settingsButton(
        _ buttonLabel: String,
        tag: String,
        action: @escaping () -> Void
    ) -> some View {
        Button { action() }
        label: {
            Text(buttonLabel)
                .padding(.vertical, 2)
                .padding(.horizontal, 5)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
        .hoverAnimation()
        
    }
    
    func hoverAnimation() -> some View {
        modifier(HoverAnimationModifier())
    }
    

}

