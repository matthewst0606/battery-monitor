//
//  GpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

// ------------------------------------------------------
//  ===== GPU Powermetrics View in Powermetrics tab =====
//  -----------------------------------------------------
struct GpuTabView: View {
    @EnvironmentObject var model: ModelService
    
    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ForEach(listItems(for: result)) { metric in
                        ListItem(
                            title: metric.title,
                            value: metric.value,
                            color: metric.color
                        )
                    }
                }
                else { LoadingScreen() }
            }.unscrollableListStyle()
        }.smallPanelStyle()
    }
    
    // -------------------------
    // ===== Standard Rows =====
    // -------------------------
    private func listItems(for result: PythonResult) -> [MetricRow] {
        [
            MetricRow(
                title: "GPU Usage",
                value: String(format: "%.2f%%", result.gpuUsage),
                color: .primary
            ),
            MetricRow(
                title: "GPU Idle",
                value: String(format: "%.2f%%", result.gpuIdle),
                color: .primary
            ),
            MetricRow(
                title: "GPU Power",
                value: String(format: "%.2f W", result.gpuPower),
                color: .primary
            ),
            MetricRow(
                title: "GPU Frequency",
                value: String(format: "%.2f Mhz", result.gpuFrequency),
                color: .primary
            ),
            MetricRow(
                title: "GPU Residency",
                value: String(format: "%.2f%%", result.gpuResidency),
                color: .primary
            ),
        ]
    }
}
