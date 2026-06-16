//
//  BatteryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//
import SwiftUI
import Charts


struct BatteryPowermetricsView: View {
    @EnvironmentObject var modelRunner: PythonModelRunner
    @State private var out = ""
        
    var body: some View {
        VStack(spacing: 5) {
            List {
                ListItem(arg1: "Current Charge", arg2: String("\(modelRunner.batteryPercent)%"))
                ListItem(arg1: "Battery Health", arg2: String("\(modelRunner.batteryCondition)%"))
                ListItem(arg1: "Cycle Count", arg2: "\(modelRunner.cycleCount)")
                ListItem(arg1: "Current Battery Prediction", arg2: String(modelRunner.timeRemaining))
            }
            .unscrollableListStyle()
        }
        .appTabStyle()
    }
}




struct BatteryTabView: View {
    @EnvironmentObject var monitor: BatteryMonitor

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let battInfo = monitor.info {
                    ListItem(arg1: "Battery Level", arg2: "\(battInfo.batteryLevel)%")
                    ListItem(arg1: "Battery Health", arg2: "\(battInfo.batteryHealth)%")
                    ListItem(arg1: "Is Charging?", arg2: "\(battInfo.isCharging ? "yes" : "no")")
                    ListItem(arg1: "Time Remaining", arg2: "\(monitor.timeRemainingText)")
                }
            }
            .unscrollableListStyle()


        }
        .appTabStyle()
    }

}


