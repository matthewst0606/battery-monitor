//
//  ViewExtension.swift
//  Battery Monitor
//
//  Created by Matt on 6/1/26.
//
import SwiftUI
import SwiftfulLoadingIndicators

// a standard loading screen
struct LoadingScreen: View {
    
    var body: some View {
            HStack(alignment: .center) {
                Text("Loading")
                LoadingIndicator(animation: .threeBalls, size: .small)
                
            }.frame(maxWidth: .infinity)
    }
}


extension View {
    // creates a button tab
    // e.g. stats, powermetrics
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

    // the standard format for buttons
    // in the settings view
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
    
    // a hovering animation for buttons
    func hoverAnimation() -> some View {
        modifier(HoverAnimationModifier())
    }
}
