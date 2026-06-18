//
//  PowermetricsTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/18/26.
//

import SwiftUI

struct PowermetricsTabView: View {
    @EnvironmentObject var modelRunner: PythonModelRunner
    @EnvironmentObject var cpu: CPUService
    @EnvironmentObject var mem: MemoryService
    
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor

    @State private var selectedStat = "batt"
    @State private var selectedPowermetrics = "batt"
    
    // powermetrics page tabs
    private var BatteryPowermetrics: some View {
        BatteryPowermetricsView()
            .environmentObject(modelRunner)
    }
    private var CPUPowermetrics: some View {
        CPUPowermetricsView()
            .environmentObject(modelRunner)
    }
    private var MemoryPowermetrics: some View {
        MemoryPowermetricsView()
    }
    private var GPUView: some View {
        GpuTabView()
            .environmentObject(modelRunner)
    }
    private var ProcessesView: some View {
        ProcessesTabView()
            .environmentObject(modelRunner)
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

    }
    
}
