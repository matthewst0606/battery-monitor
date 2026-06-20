//
//  GpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

struct GpuTabView: View {
    @EnvironmentObject var model: PythonModelRunner

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ListItem(arg1: "GPU Usage", arg2: String(format: "%.2f%%", result.GpuUsage), arg3: .primary)
                    ListItem(arg1: "GPU Idle", arg2: String(format: "%.2f%%", result.GpuIdle), arg3: .primary)
                    ListItem(arg1: "GPU Power", arg2: String(format: "%.2f W", result.GpuPower), arg3: .primary)
                    ListItem(arg1: "GPU Frequency", arg2: String(format: "%.2f Mhz", result.GpuFrequency), arg3: .primary)
                    ListItem(arg1: "GPU Residency", arg2: String(format: "%.2f%%", result.GpuResidency), arg3: .primary)
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}
