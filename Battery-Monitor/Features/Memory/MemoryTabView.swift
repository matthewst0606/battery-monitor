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
                    ListItem("Total Memory", value: String(format: "%.2fGB", result.totalMemory), color: .primary)
                    ListItem("Used Memory", value: String(format: "%.2fGB", result.usedMemory), color: .primary)
                }
            }.unscrollableListStyle()
        }.appTabStyle()
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
                        chartMetrics.row(
                            title: "Total Memory",
                            value: String(format: "%.2f GB", memory.total),
                            color: .primary,
                            chart: .memoryTotal(maxGB: memory.total)
                        )
                        chartMetrics.row(
                            title: "Cached Memory",
                            value: String(format: "%.2f GB", memory.cached),
                            color: .primary,
                            chart: .memoryCached(maxGB: memory.total)
                        )

                        
                        chartMetrics.row(
                            title: "Used Memory",
                            value: String(format: "%.2f GB", memory.used),
                            color: memoryUsedColor(Int(memory.used)),
                            chart: .memoryUsed(maxGB: memory.total)
                        )
                        
                        chartMetrics.row(
                            title: "Available Memory",
                            value: String(format: "%.2f GB", memory.available),
                            color: memoryAvailableColor(Int(memory.available)),
                            chart: .memoryAvailable(maxGB: memory.total)
                        )

            
                    }
                }.scrollableListStyle()
            }.appTabStyle()
        }
    }
    

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
        case 0..<3:  return .red
        case 3..<5: return .orange
        case 5...:   return .yellow
        default:      return .green
        }
    }
}

struct MemoryMenuView: View {
    @State private var test: Bool = true

    var body: some View {
        Toggle("Total Memory", isOn: $test)
        Toggle("Cached Memory", isOn: $test)
        Toggle("Used Memory", isOn: $test)
        Toggle("Available Memory", isOn: $test)
    }
}
