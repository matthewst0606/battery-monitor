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
    @EnvironmentObject var modelRunner: PythonModelRunner
    @EnvironmentObject var cpu: CPUService
    @EnvironmentObject var mem: MemoryService


    @ViewBuilder private var BatteryPowermetrics: some View {BatteryPowermetricsView()}
    @ViewBuilder private var BatteryTab: some View {BatteryTabView().environmentObject(monitor)}
    @ViewBuilder private var CPUPowermetrics: some View {CPUPowermetricsView()}
    @ViewBuilder private var CPUTab: some View {CPUTabView().environmentObject(cpu)}
    @ViewBuilder private var MemoryPowermetrics: some View {MemoryPowermetricsView()}
    @ViewBuilder private var MemoryTab: some View {MemoryTabView().environmentObject(mem)}
    
    @ViewBuilder private var GPUView: some View {GpuTabView().environmentObject(modelRunner)}
    @ViewBuilder private var ProcessesView: some View {ProcessesTabView().environmentObject(modelRunner)}
    @ViewBuilder private var ModelTab: some View {ModelTabView().environmentObject(modelRunner)}
    
    
    @State private var selectedStat = "batt"
    @State private var selectedPowermetrics = "batt"
    @State private var pythonOutput = ""

    @State private var pressedButton: String? = nil
    
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor

    
    var ThisMacView: some View {
        VStack {
            Text("This Mac")
                .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                .font(.system(size: 18, weight: .bold))
            
            Image(systemName: "macbook.gen2")
                .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                .imageScale(.large)
                .foregroundStyle(Color.primary, Color.dataToColor(from: selectedColorData) ?? selectedAccentColor)

                List {
                    ListItem(arg1: "Chip", arg2: "\(cpu.getChipName())", arg3: .primary)
                    ListItem(arg1: "Memory", arg2: "\(Int(mem.info!.total)) GB", arg3: .primary)
                    ListItem(arg1: "Version", arg2: "\(ProcessInfo.processInfo.operatingSystemVersionString)", arg3: .primary)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .frame(minWidth: 300, maxWidth: 500)
                .frame(height: 100)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    var ModelPredictionView: some View {
        VStack {
            Text("Model Predictions")
                .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                .font(.system(size: 18, weight: .bold))
            
            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                .imageScale(.large)
                .foregroundStyle(Color.primary, Color.dataToColor(from: selectedColorData) ?? selectedAccentColor)

                List {
                    ListItem(arg1: "Chip", arg2: "\(cpu.getChipName())", arg3: .primary)
                    ListItem(arg1: "Memory", arg2: "\(Int(mem.info!.total)) GB", arg3: .primary)
                    ListItem(arg1: "Version", arg2: "\(ProcessInfo.processInfo.operatingSystemVersionString)", arg3: .primary)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .frame(minWidth: 300, maxWidth: 500)
                .frame(height: 100)
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
                        case "batt": BatteryTab
                        case "cpu": CPUTab
                        case "mem": MemoryTab
                        default: BatteryTab
                    }
                }
                .padding(20)
                .frame(minWidth: 500, maxHeight: .infinity, alignment: .top)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .navigationTitle(Text("Stats"))

            }
                

            

            Tab("Powermetrics", systemImage: "bolt.fill") {
                VStack(alignment: .center, spacing: 10) {
                    ModelPredictionView

                    HStack {
                        createTab(title: "Battery", tag: "batt", selectedStat: $selectedPowermetrics)
                        createTab(title: "CPU", tag: "cpu", selectedStat: $selectedPowermetrics)
                        createTab(title: "GPU", tag: "gpu", selectedStat: $selectedPowermetrics)
                        createTab(title: "Memory", tag: "mem", selectedStat: $selectedPowermetrics)
                        createTab(title: "Processes", tag: "processes", selectedStat: $selectedPowermetrics)
                    }
                    .frame(minWidth: 300, maxWidth: 500)

                    
                    
                    switch selectedPowermetrics {
                        case "batt":  BatteryPowermetrics.environmentObject(modelRunner)
                        case "cpu": CPUPowermetrics.environmentObject(modelRunner)
                        case "gpu": GPUView.environmentObject(modelRunner)
                        case "mem": MemoryPowermetrics.environmentObject(modelRunner)
                        case "processes": ProcessesView.environmentObject(modelRunner)
                        default: BatteryPowermetrics
                    }
                }
                .frame(minWidth: 500, maxHeight: .infinity, alignment: .top)
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .navigationTitle(Text("Powermetrics"))
            }
            
        
            Tab("Model Logs", systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill") {
                ModelTab
            }
            
            Tab("Other", systemImage: "info.circle.fill") {
                
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .background(.ultraThinMaterial)

    }
}
