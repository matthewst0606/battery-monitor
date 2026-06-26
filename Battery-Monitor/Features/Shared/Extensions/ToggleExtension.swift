//
//  ToggleExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/17/26.
//

import SwiftUI

extension Toggle {
    func getToggleStyle() -> some View {
        self
            .padding()
            .toggleStyle(.switch)
    }
}
