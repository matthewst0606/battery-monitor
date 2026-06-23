//
//  WindowView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI
import AppKit
import MachO
import Darwin

struct WindowView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @EnvironmentObject var model: ModelService
    @EnvironmentObject var cpu: CPUService
    @EnvironmentObject var mem: MemoryService


    // stats page tabs
    private var CPUTab: some View {
        CPUTabView()
            .environmentObject(cpu)
    }
    
    

    private var MemoryTab: some View {
        MemoryTabView()
            .environmentObject(mem)
    }
    
    private var batteryTab: some View {
        BatteryTabView()
            .environmentObject(monitor)

    }
    
    private var PowermetricsTab: some View {
        PowermetricsTabView()
            .environmentObject(mem)
            .environmentObject(cpu)
            .environmentObject(model)
    }


    private var ModelTab: some View {
        ModelTabView()
            .environmentObject(model)
    }
    
    
    @State private var selectedStat = "batt"
    @State private var selectedPowermetrics = "batt"
    @State private var pythonOutput = ""
    @State private var pressedButton: String? = nil
    
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor

    
    var ThisMacView: some View {
        VStack {
            HStack {
                Text("This Mac")
                    .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                    .font(.system(size: 18, weight: .bold))
                
                Image(systemName: "macbook.gen2")
                    .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                    .imageScale(.large)
                    .foregroundStyle(Color.primary, Color.dataToColor(from: selectedColorData) ?? selectedAccentColor)
            }


                List {
                    ListItem(arg1: "Chip", arg2: "\(cpu.getChipName())", arg3: .primary)
                    ListItem(arg1: "Memory", arg2: "\(Int(mem.info!.total)) GB", arg3: .primary)
                    ListItem(arg1: "Version", arg2: "\(ProcessInfo.processInfo.operatingSystemVersionString)", arg3: .primary)
                    ListItem(arg1: "System Uptime", arg2: monitor.formatHMS(monitor.info!.uptime), arg3: .primary)

                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .frame(minWidth: 300, maxWidth: 500)
                .frame(height: 200)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    



    var body: some View {
        TabView() {
            Tab("Stats", systemImage: "macbook.gen2") {
                VStack(alignment: .center, spacing: 10) {
                    ThisMacView
                    
                    HStack {
                        createTab(title: "Battery", tag: "batt", selectedStat: $selectedStat)
                        createTab(title: "CPU", tag: "cpu", selectedStat: $selectedStat)
                        createTab(title: "Memory", tag: "mem", selectedStat: $selectedStat)
                    }
                    .frame(minWidth: 300, maxWidth: 500)


                    switch selectedStat {
                        case "batt": batteryTab
                        case "cpu": CPUTab
                        case "mem": MemoryTab
                        default: batteryTab
                    }
                }
                .windowTabStyle(title: "Stats")
            }
                
            Tab("Powermetrics", systemImage: "bolt.fill") {
                VStack(alignment: .center, spacing: 10) {
                    PowermetricsTab
                        .windowTabStyle(title: "Powermetrics")
                }
            }
            
        
            Tab("Model Logs", systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill") {
                ModelTab
            }
            
            Tab("Other", systemImage: "info.circle.fill") { }
        }
        .background(.ultraThinMaterial)
        .onAppear() {
            if !model.isRunningPython {
                model.updatePy()
            }
        }

    }
}
