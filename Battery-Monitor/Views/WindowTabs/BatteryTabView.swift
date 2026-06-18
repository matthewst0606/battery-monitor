//
//  BatteryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//
import SwiftUI
import Charts

private func formatBatteryPrediction(_ value: Double) -> String {
    let raw = Int(value.rounded())
    let hours = raw / 100
    let minutes = raw % 100
    return "\(hours)h \(minutes)m"
}

struct BatteryPowermetricsView: View {
    @EnvironmentObject var modelRunner: PythonModelRunner
        
    var body: some View {
        VStack(spacing: 5) {
            List {
                ListItem(arg1: "Current Charge", arg2: String("\(modelRunner.batteryPercent)%"), arg3: .primary)
                ListItem(arg1: "Battery Condition", arg2: String("\(modelRunner.batteryCondition)"), arg3: .primary)
                ListItem(arg1: "Cycle Count", arg2: "\(modelRunner.cycleCount)", arg3: .primary)
                ListItem(arg1: "Current Battery Prediction", arg2: String(formatBatteryPrediction(modelRunner.timeRemaining)), arg3: .primary)
                
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}




struct BatteryTabView: View {
    @EnvironmentObject var monitor: BatteryMonitor

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let battInfo = monitor.info {

                    
                    switch battInfo.batteryLevel {
                    case 75...100: ListItem(arg1: "Battery Level", arg2: "\(battInfo.batteryLevel)%", arg3: .green)
                    case 50...75:  ListItem(arg1: "Battery Level", arg2: "\(battInfo.batteryLevel)%", arg3: .yellow)
                    case 25...50:  ListItem(arg1: "Battery Level", arg2: "\(battInfo.batteryLevel)%", arg3: .orange)
                    default:       ListItem(arg1: "Battery Level", arg2: "\(battInfo.batteryLevel)%", arg3: .red)
                    }
                        
                    switch battInfo.batteryHealth {
                    case 85...100: ListItem(arg1: "Battery Health", arg2: "\(battInfo.batteryHealth)%", arg3: .green)
                    case 80...85:  ListItem(arg1: "Battery Health", arg2: "\(battInfo.batteryHealth)%", arg3: .orange)
                    default:       ListItem(arg1: "Battery Health", arg2: "\(battInfo.batteryHealth)%", arg3: .red)
                    }
                                    
                    switch battInfo.timeRemaining {
                    case 1000...2000: ListItem(arg1: "Time Remaining", arg2: "\(monitor.timeRemainingText)", arg3: .green)
                    case 500...1000:  ListItem(arg1: "Time Remaining", arg2: "\(monitor.timeRemainingText)", arg3: .yellow)
                    case 300...500:   ListItem(arg1: "Time Remaining", arg2: "\(monitor.timeRemainingText)", arg3: .orange)
                    case 0...300:   ListItem(arg1: "Time Remaining", arg2: "\(monitor.timeRemainingText)", arg3: .red)
                    default:                ListItem(arg1: "Time Remaining", arg2: "calculating...", arg3: .primary)
                    }
                    
                    switch battInfo.isCharging {
                    case true:  ListItem(arg1: "Charging Status", arg2: "yes", arg3: .green)
                    default:    ListItem(arg1: "Charging Status", arg2: "no", arg3: .primary)
                    }
                    
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}


