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
                    ListItem(
                        "Current Charge",
                        value: String("\(result.batteryPercent)%"),
                        color: .primary
                    )
                    ListItem(
                        "Battery Condition",
                        value: String("\(result.condition)"),
                        color: .primary
                    )
                    ListItem(
                        "Cycle Count",
                        value: "\(result.cycleCount)",
                        color: .primary
                    )
                    ListItem(
                        "Current Battery Prediction",
                        value: model.formatBatteryPrediction(result.timeRemaining),
                        color: .primary
                    )
                }
            }.unscrollableListStyle()
        }.appTabStyle()
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
                        chartMetrics.row(
                            title: "Battery Level",
                            value: "\(battInfo.batteryLevel)%",
                            color: batteryLevelColor(battInfo.batteryLevel),
                            chart: .batteryLevel
                        )

                        chartMetrics.row(
                            title: battInfo.powerSourceState == "AC Power" ? "Time to Full" : "Time Remaining",
                            value: "\(battery.timeRemainingText)",
                            color: timeRemainingColor(Int(battInfo.timeRemaining), battInfo.powerSourceState),
                            chart: .batteryTimeRemaining
                        )
                        
                        chartMetrics.row(
                            title: "Battery Temperature",
                            value: String(format: "%.2f ℃", battInfo.temperature),
                            color: .primary,
                            chart: .batteryTemperature
                        )
                        
                        
                        ListItem(
                            "Max Capacity",
                            value: "\(battInfo.maxCapacity)%",
                            color: maxCapacityColor(battInfo.maxCapacity),
                        )
                        
                        ListItem(
                            "Power Source",
                            value: "\(battInfo.powerSourceState)",
                            color: .primary
                        )

                        switch battInfo.powerMode {
                        case 1:  ListItem("Low Power Mode", value: "On", color: .primary)
                        default: ListItem("Low Power Mode", value: "Off", color: .primary)
                        }
                        
                    }
                }.scrollableListStyle()
            }
            .appTabStyle()
        }
    }

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
        case 90...: return .green
        case 85..<90: return .yellow
        case 80..<85: return .orange
        default:      return .red
        }
    }
    
    private func timeRemainingColor(_ value: Int, _ powerSrc: String) -> Color {
        switch value {
        case 1000...: return .green
        case 500..<1000:  return .yellow
        case 300..<500:   return .orange
        case 0..<300:
            if powerSrc == "AC Power" { return .secondary }
            else { return .red }
        default:          return .secondary

        }
    }
}




struct BatteryMenuView: View {
    @State private var test: Bool = true

    var body: some View {
        Toggle("Battery Level", isOn: $test)
        Toggle("Battery Health", isOn: $test)
        Toggle("Time Remaining", isOn: $test)
        Toggle("Power Source", isOn: $test)
        Toggle("Battery Temperature", isOn: $test)
        Toggle("Low Power Mode", isOn: $test)
        Toggle("Charging Status", isOn: $test)
    }
}
