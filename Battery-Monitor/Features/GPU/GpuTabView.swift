//
//  GpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

struct GpuTabView: View {
    @EnvironmentObject var model: ModelService

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ListItem("GPU Usage", value: String(format: "%.2f%%", result.gpuUsage), color: .primary)
                    ListItem("GPU Idle", value: String(format: "%.2f%%", result.gpuIdle), color: .primary)
                    ListItem("GPU Power", value: String(format: "%.2f W", result.gpuPower), color: .primary)
                    ListItem("GPU Frequency", value: String(format: "%.2f Mhz", result.gpuFrequency), color: .primary)
                    ListItem("GPU Residency", value: String(format: "%.2f%%", result.gpuResidency), color: .primary)
                }
                else { loading() }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}
