//
//  MemoryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI
import Combine

struct MemoryPowermetricsView: View {
    @EnvironmentObject var model: ModelService

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ForEach(listItems(for: result)) { metric in
                        ListItem(metric.title, value: metric.value, color: metric.color)
                    }
                }
                else { loading() }

            }.unscrollableListStyle()
        }.appTabStyle()
    }
    
    // -------------------------
    // ===== Standard Rows =====
    // -------------------------
    private func listItems(for result: PythonResult) -> [MetricRow] {
        [
            MetricRow(
                title: "Total Memory",
                value: String(format: "%.2fGB", result.totalMemory),
                color: .primary,
            ),
            MetricRow(
                title: "Cached Memory",
                value: String(format: "%.2f GB", result.usedMemory),
                color: .primary,
            ),
        ]
        
    }
    
}

struct MemoryTabView: View {
    @EnvironmentObject var mem: MemoryService

    var body: some View {
        ChartMetricScope(
            refresh: mem.$info.map { _ in }.eraseToAnyPublisher()
        ) { chartMetrics in
            VStack(spacing: 5) {
                List {
                    if let memory = mem.info {
                        ForEach(chartableItems(for: memory)) { metric in
                            chartMetrics.row(metric)
                        }
                        
                    }
                    else { loading() }

                }.scrollableListStyle()
            }.appTabStyle()
        }
    }
    
    
    // ---------------------------
    //  ===== Chartable Rows =====
    //  --------------------------
    private func chartableItems(for memory: MemoryInfo) -> [MetricRow] {
        [
            MetricRow(
                title: "Total Memory",
                value: String(format: "%.2f GB", memory.total),
                color: .primary,
                chart: .memoryTotal(maxGB: memory.total),
                visibilityKey: MemoryMenuKey.total
            ),
            MetricRow(
                title: "Cached Memory",
                value: String(format: "%.2f GB", memory.cached),
                color: .primary,
                chart: .memoryCached(maxGB: memory.total),
                visibilityKey: MemoryMenuKey.cached

            ),
            MetricRow(
                title: "Used Memory",
                value: String(format: "%.2f GB", memory.used),
                color: memoryUsedColor(Int(memory.used)),
                chart: .memoryUsed(maxGB: memory.total),
                visibilityKey: MemoryMenuKey.used

            ),
            MetricRow(
                title: "Available Memory",
                value: String(format: "%.2f GB", memory.available),
                color: memoryAvailableColor(Int(memory.available)),
                chart: .memoryAvailable(maxGB: memory.total),
                visibilityKey: MemoryMenuKey.available

            )
        ]
        
    }

    // -------------------------
    // ===== Text Coloring =====
    // -------------------------
    private func memoryUsedColor(_ value: Int) -> Color {
        switch value {
        case 0..<10:  return .green
        case 10..<20: return .yellow
        case 20...:   return .orange
        default:      return .red
        }
    }
    private func memoryAvailableColor(_ value: Int) -> Color {
        switch value {
        case 0..<3: return .red
        case 3..<5: return .orange
        case 5...:  return .yellow
        default:    return .green
        }
    }
}

// -------------------------
// ===== Menu Toggling =====
// -------------------------
struct MemoryMenuView: View {
    var body: some View {
        AppStorageToggle("Total Memory", key: MemoryMenuKey.total)
        AppStorageToggle("Cached Memory", key: MemoryMenuKey.cached)
        AppStorageToggle("Used Memory", key: MemoryMenuKey.used)
        AppStorageToggle("Available Memory", key: MemoryMenuKey.available)
    }
}
enum MemoryMenuKey {
    static let total = "total_memory"
    static let cached = "cached_memory"
    static let used = "used_memory"
    static let available = "available_memory"
}
