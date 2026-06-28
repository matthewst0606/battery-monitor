//
//  TextExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//

import SwiftUI

extension Text {
    // standard text formatting
    func standard() -> some View {
        self
            .font(.system(size: 12, weight: .bold))
            .padding(EdgeInsets(top: 5, leading: 5, bottom:  2, trailing: 5))
    }
    
    // standard text animation on click
    func textAnimation(isSelected: Bool) -> some View {
        self
            .font(.system(
                size: isSelected ? 14: 11,
                weight: isSelected ? .bold: .regular
            ))
            .padding(.horizontal, isSelected ? 0 : 5)
            .padding(.vertical, 5)  
    }
}
