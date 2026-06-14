//
//  CpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.

import SwiftUI


struct CpuTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var cpu = CPUService()

    @EnvironmentObject var modelRunner: PythonModelRunner
    
    var body: some View {

        
        VStack(alignment: .leading, spacing: 5) {
            GroupBox {
                Text("CPU Usage: \(modelRunner.CpuUsage, specifier: "%.2f")%").widgetText()
                Text("CPU Idle: \(modelRunner.CpuIdle, specifier: "%.2f")%").widgetText()
                Text("CPU Power: \(Int(modelRunner.CpuPower)) W").widgetText()
                Text("CPU Frequency: \(Int(modelRunner.CpuFrequency)) MHz").widgetText()
                Text("CPU Residency: \(modelRunner.CpuResidency, specifier: "%.2f")%").widgetText()
            }
        }
    }
}
