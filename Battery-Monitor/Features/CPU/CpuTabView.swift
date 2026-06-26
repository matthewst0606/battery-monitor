//
//  CpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
import SwiftUI
import Combine


struct CPUPowermetricsView: View {
    @EnvironmentObject var cpu: CPUService
    @EnvironmentObject var model: ModelService
    
    var body: some View {
        
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ListItem("CPU Usage", value: String(format: "%.2f%%", result.CpuUsage), color: .primary)
                    ListItem("CPU Idle", value: String(format: "%.2f%%", result.CpuIdle), color: .primary)
                    ListItem("CPU Power", value: String(format: "%.2f W", result.CpuPower), color: .primary)
                    ListItem("CPU Frequency", value: String(format: "%.2f Mhz", result.CpuFrequency), color: .primary)
                    ListItem("CPU Residency", value: String(format: "%.2f%%", result.CpuResidency), color: .primary)
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}


struct CPUTabView: View {
    @EnvironmentObject var cpu: CPUService
    
    var body: some View {
        ChartMetricScope(
            refresh: cpu.$info.map { _ in }.eraseToAnyPublisher()
        ) { chartMetrics in
            VStack(spacing: 5) {
                List {
                    if let cpu = cpu.info {
                        
                        chartMetrics.row(
                            title: "CPU Usage",
                            value: String(format: "%.2f%%", cpu.total),
                            color: cpuUsageColor(Int(cpu.total)),
                            chart: .cpuTotal
                        )
                        chartMetrics.row(
                            title: "User Usage",
                            value: String(format: "%.2f%%", cpu.user),
                            color: cpuUsageColor(Int(cpu.user)),
                            chart: .cpuUser
                        )
                        chartMetrics.row(
                            title: "System Usage",
                            value: String(format: "%.2f%%", cpu.sys),
                            color: cpuUsageColor(Int(cpu.sys)),
                            chart: .cpuSystem
                        )
                        chartMetrics.row(
                            title: "System Idle",
                            value: String(format: "%.2f%%", cpu.idle),
                            color: cpuIdleColor(Int(cpu.idle)),
                            chart: .cpuIdle
                        )
                    }
                }
                .scrollableListStyle()
            }
            .appTabStyle()
        }
    }
    
    
    private func cpuUsageColor(_ value: Int) -> Color {
        switch value {
        case 75...: return .red
        case 50..<75: return .orange
        case 25...50: return .yellow
        default: return .green
        }
    }
    
    private func cpuIdleColor(_ value: Int) -> Color {
        switch value {
        case 75...: return .green
        case 50..<75: return .yellow
        case 25...50: return .orange
        default: return .red
        }
    }
}

struct CPUMenuView: View {
    @State private var test: Bool = true

    var body: some View {
        Toggle("CPU Usage", isOn: $test)
        Toggle("User Usage", isOn: $test)
        Toggle("System Usage", isOn: $test)
        Toggle("System Idle", isOn: $test)
    }
}
