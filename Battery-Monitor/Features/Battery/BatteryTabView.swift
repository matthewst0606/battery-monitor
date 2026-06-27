//
//  BatteryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//
import SwiftUI
import Combine


struct BatteryPowermetricsView: View {
    @EnvironmentObject var model: ModelService
    
    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    
                    modelSummary(for: result)
                    
                    ForEach(listItems(for: result)) { metric in
                        ListItem(metric.title, value: metric.value, color: metric.color)
                    }

                    
                }
                else { loading() }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
    
    // -------------------------
    // ===== Summary =====
    // -------------------------
    private func modelSummary(for result: PythonResult) -> some View {
        VStack(alignment: .leading, spacing: 6) {
                Text("Summary")
                    .font(.system(size: 12, weight: .bold))
                Text("\(result.predictionSummary), \(result.drainRateDeltaText)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                Text("Confidence: \(result.confidence?.level ?? "") \(result.confidence?.reason ?? "")")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
    }
    
    // -------------------------
    // ===== Standard Rows =====
    // -------------------------
    private func listItems(for result: PythonResult) -> [MetricRow] {
        [
            MetricRow(
                title: "Current Battery Prediction",
                value: model.formatBatteryPrediction(result.timeRemaining),
                color: .primary
            ),
            MetricRow(
                title: "Drain Rate",
                value: result.drainRateText,
                color: .primary
            ),
            MetricRow(
                title: "Average Drain Rate",
                value: result.avgDrainRateText,
                color: .primary
            ),
        ]
    }
}


struct BatteryTabView: View {
    @EnvironmentObject var battery: BatteryService

    var body: some View {
        ChartMetricScope(
            refresh: battery.$info.map { _ in }.eraseToAnyPublisher()
        ) { chartMetrics in
            VStack(spacing: 5) {
                List {
                    if let battInfo = battery.info {
                        
                        ForEach(chartableItems(for: battInfo)) { metric in
                            chartMetrics.row(metric)
                        }
                        
                        ForEach(listItems(for: battInfo)) { metric in
                            chartMetrics.row(metric)
                        }

                    }
                    else {
                        loading()
                    }
                }.scrollableListStyle()
            }
            .appTabStyle()
        }
    }
    
    // ---------------------------
    //  ===== Chartable Rows =====
    //  --------------------------
    private func chartableItems(for battInfo: BatteryInfo) -> [MetricRow] {
        [
            MetricRow(
                title: "Battery Level",
                value: "\(battInfo.batteryLevel)%",
                color: batteryLevelColor(battInfo.batteryLevel),
                chart: .batteryLevel,
                visibilityKey: BatteryMenuKey.level

            ),
            MetricRow(
                title: "Battery Temperature",
                value: String(format: "%.2f ℃", battInfo.temperature),
                color: .primary,
                chart: .batteryTemperature,
                visibilityKey: BatteryMenuKey.temperature

            ),
            MetricRow(
                title: battInfo.powerSourceState == "AC Power" ? "Time to Full" : "Time Remaining",
                value: "\(battery.timeRemainingText)",
                color: timeRemainingColor(Int(battInfo.timeRemaining), battInfo.powerSourceState),
                chart: .batteryTimeRemaining,
                visibilityKey: BatteryMenuKey.timeRemaining

            ),
        ]
    }
    
    // -------------------------
    // ===== Standard Rows =====
    // -------------------------
    private func listItems(for battInfo: BatteryInfo) -> [MetricRow] {
        [
            MetricRow(
                title: "Max Capacity",
                value: "\(battInfo.maxCapacity)%",
                color: maxCapacityColor(battInfo.maxCapacity),
                visibilityKey: BatteryMenuKey.capacity
            ),
        
            MetricRow(
                title: "Power Source",
                value: "\(battInfo.powerSourceState)",
                color: .primary,
                visibilityKey: BatteryMenuKey.powerSource
            ),
        
            MetricRow (
                title: "Low Power Mode",
                value: battInfo.powerMode == 1 ? "On" : "Off",
                color: .primary,
                visibilityKey: BatteryMenuKey.lowPowerMode
            )
        ]
    }
    
    // -------------------------
    // ===== Text Coloring =====
    // -------------------------
    private func batteryLevelColor(_ value: Int) -> Color {
        switch value {
        case 75...:   return .green
        case 50..<75: return .yellow
        case 25..<50: return .orange
        default:      return .red
        }
    }
    
    private func maxCapacityColor(_ value: Int) -> Color {
        switch value {
        case 90...:   return .green
        case 85..<90: return .yellow
        case 80..<85: return .orange
        default:      return .red
        }
    }
    
    private func timeRemainingColor(_ value: Int, _ powerSrc: String) -> Color {
        if powerSrc == "AC Power" { return .primary }

        switch value {
        case 1000...:     return .green
        case 500..<1000:  return .yellow
        case 300..<500:   return .orange
        case 0..<300:     return .red
        default:          return .secondary
        }
    }
}



// -------------------------
// ===== Menu Toggling =====
// -------------------------
struct BatteryMenuView: View {
    var body: some View {
        AppStorageToggle("Battery Level", key: BatteryMenuKey.level)
        AppStorageToggle("Max Capacity", key: BatteryMenuKey.capacity)
        AppStorageToggle("Time Remaining", key: BatteryMenuKey.timeRemaining)
        AppStorageToggle("Power Source", key: BatteryMenuKey.powerSource)
        AppStorageToggle("Battery Temperature", key: BatteryMenuKey.temperature)
        AppStorageToggle("Low Power Mode", key: BatteryMenuKey.lowPowerMode)
        AppStorageToggle("Charging Status", key: BatteryMenuKey.chargingStatus)
    }
}

enum BatteryMenuKey {
    static let level = "show_battery_level"
    static let capacity = "show_battery_capacity"
    static let timeRemaining = "show_time_remaining"
    static let powerSource = "show_power_source"
    static let temperature = "show_battery_temperature"
    static let lowPowerMode = "show_low_power_mode"
    static let chargingStatus = "show_charging_status"        
}
