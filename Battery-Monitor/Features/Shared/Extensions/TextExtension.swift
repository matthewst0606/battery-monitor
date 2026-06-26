//
//  TextExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//

import SwiftUI

extension Text {
    func standard() -> some View {
        self
            .font(.system(size: 12, weight: .bold))
            .padding(EdgeInsets(top: 5, leading: 5, bottom:  2, trailing: 5))
    }
    
    func textAnimation(isSelected: Bool) -> some View {
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
