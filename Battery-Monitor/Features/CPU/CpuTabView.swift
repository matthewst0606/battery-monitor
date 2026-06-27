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
                    ForEach(listItems(for: result)) { metric in
                        ListItem(
                            metric.title,
                            value: metric.value,
                            color: metric.color
                        )
                    }
                }
                else { loading() }
            }
            .unscrollableListStyle()
        }
        .appTabStyle()
    }
    
    // -------------------------
    // ===== Standard Rows =====
    // -------------------------
    private func listItems(for result: PythonResult) -> [MetricRow] {
        [
            MetricRow(
                title: "CPU Usage",
                value: String(format: "%.2f%%", result.cpuUsage),
                color: .primary
            ),
            MetricRow(
                title: "CPU Idle",
                value: String(format: "%.2f%%", result.cpuIdle),
                color: .primary
            ),
            MetricRow(
                title: "CPU Power",
                value: String(format: "%.2f W", result.cpuPower),
                color: .primary
            ),
            MetricRow(
                title: "CPU Frequency",
                value: String(format: "%.2f Mhz", result.cpuFrequency),
                color: .primary
            ),
            MetricRow(
                title: "CPU Residency",
                value: String(format: "%.2f%%", result.cpuResidency),
                color: .primary
            ),
        ]
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
                    if let cpuInfo = cpu.info {
                        ForEach(chartableItems(for: cpuInfo)) { metric in
                            chartMetrics.row(metric)
                        }
                    }
                    else { loading() }
                }
                .scrollableListStyle()
            }
            .appTabStyle()
        }
    }
    
    
    // ---------------------------
    //  ===== Chartable Rows =====
    //  --------------------------
    private func chartableItems(for cpu: CPUInfo) -> [MetricRow] {
        [
            MetricRow(
                title: "CPU Usage",
                value: String(format: "%.2f%%", cpu.total),
                color: cpuUsageColor(Int(cpu.total)),
                chart: .cpuTotal,
                visibilityKey: CPUMenuKey.total
            ),
            MetricRow(
                title: "User Usage",
                value: String(format: "%.2f%%", cpu.user),
                color: cpuUsageColor(Int(cpu.user)),
                chart: .cpuUser,
                visibilityKey: CPUMenuKey.user
            ),
            MetricRow(
                title: "System Usage",
                value: String(format: "%.2f%%", cpu.sys),
                color: cpuUsageColor(Int(cpu.sys)),
                chart: .cpuSystem,
                visibilityKey: CPUMenuKey.system
            ),
            MetricRow(
                title: "System Idle",
                value: String(format: "%.2f%%", cpu.idle),
                color: cpuIdleColor(Int(cpu.idle)),
                chart: .cpuIdle,
                visibilityKey: CPUMenuKey.idle
            )
        ]
    }
    
    // -------------------------
    // ===== Text Coloring =====
    // -------------------------
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
        case 25..<50: return .orange
        default: return .red
        }
    }
    
    
}

// -------------------------
// ===== Menu Toggling =====
// -------------------------
struct CPUMenuView: View {
    var body: some View {
        AppStorageToggle("CPU Usage", key: CPUMenuKey.total)
        AppStorageToggle("User Usage", key: CPUMenuKey.user)
        AppStorageToggle("System Usage", key: CPUMenuKey.system)
        AppStorageToggle("System Idle", key: CPUMenuKey.idle)
    }
}

enum CPUMenuKey {
    static let total = "cpu_usage"
    static let user = "user_usage"
    static let system = "system_usage"
    static let idle = "idle_usage"

}
