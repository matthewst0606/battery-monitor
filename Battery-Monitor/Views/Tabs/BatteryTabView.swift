//
//  BatteryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//
import SwiftUI


struct BatteryTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Current Charge: \(Int(monitor.batteryLevel))%")
            Text("Battery Health: \(Int(monitor.batteryHealth))")
            Text("Cycle Count: \(Int())")
            Text("Current Battery Prediction: \(Int())")
        }
    }
}
