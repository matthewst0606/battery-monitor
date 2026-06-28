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
            .scrollContentBackground(.hidden)
            .background(.quinary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scrollDisabled(true)
    }
    func scrollableListStyle() -> some View {
        self
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .background(.quinary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct ListItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).standard().foregroundStyle(color)
        }
        .standardPadding()
        .listRowSeparatorTint(Color.primary.opacity(0.5))
    }
}

struct HeaderItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title).standard()
            Spacer()
            Text(value).standard()
        }
        .listRowSeparatorTint(.primary.opacity(0.05))
        .listRowBackground(Color.clear)
    }
}
