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
                ListItem(arg1: "CPU Usage", arg2: String(format: "%.2f%%", modelRunner.CpuUsage), arg3: .primary)
                ListItem(arg1: "CPU Idle", arg2: String(format: "%.2f%%", modelRunner.CpuIdle), arg3: .primary)
                ListItem(arg1: "CPU Power", arg2: String(format: "%.2f W", modelRunner.CpuPower), arg3: .primary)
                ListItem(arg1: "CPU Frequency", arg2: String(format: "%.2f Mhz", modelRunner.CpuFrequency), arg3: .primary)
                ListItem(arg1: "CPU Residency", arg2: String(format: "%.2f%%", modelRunner.CpuResidency), arg3: .primary)
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}


struct CPUTabView: View {
    @EnvironmentObject var cpu: CPUService
    
    var body: some View {
        VStack(spacing: 5) {
            List {
                if let cpu = cpu.info {
                    
                    switch cpu.total {
                    case 75...100: ListItem(arg1: "CPU Usage", arg2: String(format: "%.2f%%", cpu.total), arg3: .red)
                    case 50...75:  ListItem(arg1: "CPU Usage", arg2: String(format: "%.2f%%", cpu.total), arg3: .orange)
                    default:       ListItem(arg1: "CPU Usage", arg2: String(format: "%.2f%%", cpu.total), arg3: .green)
                    }
                    
                    switch cpu.user {
                    case 75...100: ListItem(arg1: "User Usage", arg2: String(format: "%.2f%%", cpu.user), arg3: .red)
                    case 50...75:  ListItem(arg1: "User Usage", arg2: String(format: "%.2f%%", cpu.user), arg3: .orange)
                    case 25...50:  ListItem(arg1: "User Usage", arg2: String(format: "%.2f%%", cpu.user), arg3: .yellow)
                    default:       ListItem(arg1: "User Usage", arg2: String(format: "%.2f%%", cpu.user), arg3: .green)
                    }
                    
                    switch cpu.sys {
                    case 75...100: ListItem(arg1: "System Usage", arg2: String(format: "%.2f%%", cpu.sys), arg3: .red)
                    case 50...75:  ListItem(arg1: "System Usage", arg2: String(format: "%.2f%%", cpu.sys), arg3: .orange)
                    case 25...50:  ListItem(arg1: "System Usage", arg2: String(format: "%.2f%%", cpu.sys), arg3: .yellow)
                    default:       ListItem(arg1: "System Usage", arg2: String(format: "%.2f%%", cpu.sys), arg3: .green)
                    }
                    
                    switch cpu.idle {
                    case 0...25:  ListItem(arg1: "System Idle", arg2: String(format: "%.2f%%", cpu.idle), arg3: .red)
                    case 25...50:  ListItem(arg1: "System Idle", arg2: String(format: "%.2f%%", cpu.idle), arg3: .orange)
                    case 50...75:  ListItem(arg1: "System Idle", arg2: String(format: "%.2f%%", cpu.idle), arg3: .yellow)
                    default:       ListItem(arg1: "System Idle", arg2: String(format: "%.2f%%", cpu.idle), arg3: .green)
                    }
                    
                }
            }
            .unscrollableListStyle()
        }
        .appTabStyle()
    }
}
