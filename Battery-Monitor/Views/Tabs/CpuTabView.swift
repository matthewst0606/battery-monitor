//
//  CpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
import SwiftUI


struct CPUPowermetricsView: View {
    @EnvironmentObject var cpu: CPUService
    @EnvironmentObject var modelRunner: PythonModelRunner
    
    var body: some View {
        
        VStack(spacing: 5) {
            List {
                ListItem(arg1: "CPU Usage", arg2: String(format: "%.2f%%", modelRunner.CpuUsage))
                ListItem(arg1: "CPU Idle", arg2: String(format: "%.2f%%", modelRunner.CpuIdle))
                ListItem(arg1: "CPU Power", arg2: String(format: "%.2f W", modelRunner.CpuPower))
                ListItem(arg1: "CPU Frequency", arg2: String(format: "%.2f Mhz", modelRunner.CpuFrequency))
                ListItem(arg1: "CPU Residency", arg2: String(format: "%.2f%%", modelRunner.CpuResidency))
            }
            .unscrollableListStyle()
        }
        .appTabStyle()
    }
}


struct CPUTabView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @EnvironmentObject var cpu: CPUService
    
    var body: some View {
        VStack(spacing: 5) {
            List {
                if let info = cpu.info {
                    ListItem(arg1: "CPU Usage", arg2: String(format: "%.2f%%", info.total))
                    ListItem(arg1: "User", arg2: String(format: "%.2f%%", info.user))
                    ListItem(arg1: "System", arg2: String(format: "%.2f%%", info.sys))
                    ListItem(arg1: "Idle", arg2: String(format: "%.2f%%", info.idle))
                }
            }
            .unscrollableListStyle()
            
        }
        .appTabStyle()
    }
}
