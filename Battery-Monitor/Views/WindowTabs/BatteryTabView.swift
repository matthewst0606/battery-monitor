//
//  BatteryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//
import SwiftUI
import Charts



struct BatteryPowermetricsView: View {
    @EnvironmentObject var model: ModelService
        
    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ListItem(arg1: "Current Charge", arg2: String("\(result.batteryPercent)%"), arg3: .primary)
                    ListItem(arg1: "Battery Condition", arg2: String("\(result.condition)"), arg3: .primary)
                    ListItem(arg1: "Cycle Count", arg2: "\(result.cycleCount)", arg3: .primary)
                    ListItem(arg1: "Current Battery Prediction", arg2: model.formatBatteryPrediction(result.timeRemaining), arg3: .primary)
                }
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
                    case 0...300:
                        if monitor.timeRemainingText == "0:00" && battInfo.powerSourceState == "AC Power"
                            { ListItem(arg1: "Time Remaining", arg2: "Fully Charged", arg3: .green) }
                        else
                            { ListItem(arg1: "Time Remaining", arg2: "\(monitor.timeRemainingText)", arg3: .red) }
                    default: ListItem(arg1: "Time Remaining", arg2: "calculating...", arg3: .primary)
                    }
                    
                    ListItem(arg1: "Power Source", arg2: "\(battInfo.powerSourceState)", arg3: .primary)
                    ListItem(arg1: "Battery Temperature", arg2: "\(battInfo.temperature) ℃", arg3: .primary)

                    
                    switch battInfo.powerMode {
                    case 1: ListItem(arg1: "Low Power Mode", arg2: "On", arg3: .primary)
                    default: ListItem(arg1: "Low Power Mode", arg2: "Off", arg3: .primary)
                    }

                    
                    switch battInfo.isCharging {
                    case true:  ListItem(arg1: "Charging Status", arg2: "Yes", arg3: .primary)
                    default:    ListItem(arg1: "Charging Status", arg2: "No", arg3: .primary)
                    }
                    
                    
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}


