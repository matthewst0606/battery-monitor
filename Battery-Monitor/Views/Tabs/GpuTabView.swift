//
//  GpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

struct GpuTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @EnvironmentObject var modelRunner: PythonModelRunner

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            GroupBox {
                Text("GPU Usage: \(modelRunner.GpuUsage, specifier: "%.2f")%").widgetText()
                Text("GPU Idle: \(modelRunner.GpuIdle, specifier: "%.2f")%").widgetText()
                Text("GPU Power: \(Int(modelRunner.GpuPower)) W").widgetText()
                Text("GPU Frequency: \(Int(modelRunner.GpuFrequency)) MHz").widgetText()
                Text("GPU Residency: \(modelRunner.GpuResidency, specifier: "%.2f")%").widgetText()
                
            }
        }
    }
}
