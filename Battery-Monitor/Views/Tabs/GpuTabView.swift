//
//  GpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

struct GpuTabView: View {
    @EnvironmentObject var modelRunner: PythonModelRunner

    var body: some View {
        VStack(spacing: 5) {
            List {
                ListItem(arg1: "GPU Usage", arg2: String(format: "%.2f%%", modelRunner.GpuUsage))
                ListItem(arg1: "GPU Idle", arg2: String(format: "%.2f%%", modelRunner.GpuIdle))
                ListItem(arg1: "GPU Power", arg2: String(format: "%.2f W", modelRunner.GpuPower))
                ListItem(arg1: "GPU Frequency", arg2: String(format: "%.2f Mhz", modelRunner.GpuFrequency))
                ListItem(arg1: "GPU Residency", arg2: String(format: "%.2f%%", modelRunner.GpuResidency))
            }
            .unscrollableListStyle()
        }
        .appTabStyle()
    }
}
