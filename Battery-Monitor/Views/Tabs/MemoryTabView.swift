//
//  MemoryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

struct MemoryTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @EnvironmentObject var modelRunner: PythonModelRunner

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            GroupBox {
                Text("Total Memory: \(modelRunner.totalMemory, specifier: "%.2f") GB").widgetText()
                Text("Used Memory: \(modelRunner.usedMemory, specifier: "%.2f") GB").widgetText()
            }
        }
    }
}
