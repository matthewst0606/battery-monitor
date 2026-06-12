//
//  BatteryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//
import SwiftUI


struct BatteryTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @EnvironmentObject var modelRunner: PythonModelRunner

    var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("Current Charge: \(Int(monitor.batteryLevel))%").widgetText()
                Text("Battery Health: \(monitor.batteryHealth)").widgetText()
                Text("Cycle Count: \(modelRunner.cycleCount)").widgetText()
                Text("Current Battery Prediction: \(Int(modelRunner.timeRemaining))").widgetText()
            }
            .padding()
            .frame(width: 260, height: 160, alignment: .topLeading)
            .background(.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
    }

}
