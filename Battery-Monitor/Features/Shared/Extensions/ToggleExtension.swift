//
//  ToggleExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/17/26.
//

import SwiftUI

// store the state (on/off) of displayed rows 
// in the stats tab
struct AppStorageToggle: View {
    let title: String
    @AppStorage private var isOn: Bool

    init(_ title: String, key: String, defaultValue: Bool = true) {
        self.title = title
        self._isOn = AppStorage(wrappedValue: defaultValue, key)
    }

    var body: some View {
        Toggle(title, isOn: $isOn)
    }
}

