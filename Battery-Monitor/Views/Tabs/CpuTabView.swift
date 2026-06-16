//
//  CpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
import SwiftUI


struct CPUPowermetricsView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @EnvironmentObject var cpu: CPUService
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





struct CPUTabView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @EnvironmentObject var cpu: CPUService
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("CPU").font(.system(size: 14, weight: .bold))
                Image(systemName: "cpu").imageScale(.large)
            }
            List {
                if let info = cpu.info {
                    HStack {
                        Text("Total Usage:").ListText()
                        Spacer()
                        Text("\(info.total, specifier: "%.2f")%").ListText()
                    }
                    
                    HStack {
                        Text("User Usage:").ListText()
                        Spacer()
                        Text("\(info.user, specifier: "%.2f")%").ListText()
                    }
                    
                    HStack {
                        Text("System Usage:").ListText()
                        Spacer()
                        Text("\(info.sys, specifier: "%.2f")%").ListText()
                    }
                    
                    HStack {
                        Text("Idle:").ListText()
                        Spacer()
                        Text("\(info.idle, specifier: "%.2f")%").ListText()
                    }
                }
            }
            .unscrollableListStyle()
            
        }
        .appTabStyle()
    }
}
