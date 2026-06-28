//
//  PowermetricsTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/18/26.
//

import SwiftUI

struct PowermetricsTabView: View {
    @EnvironmentObject var model: ModelService
    @EnvironmentObject var cpu: CPUService
    @EnvironmentObject var mem: MemoryService
    
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor
    @State private var selectedPowermetrics = "batt"
    
    // powermetrics page tabs
    private var BatteryPowermetrics: some View { BatteryPowermetricsView() }
    private var CPUPowermetrics: some View { CPUPowermetricsView() }
    private var MemoryPowermetrics: some View { MemoryPowermetricsView() }
    private var GPUView: some View { GpuTabView() }
    private var ProcessesView: some View { ProcessesTabView() }

    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            VStack {
                List {
                    header()
                }
                .unscrollableListStyle()
                .frame(minWidth: 300, maxWidth: 500)
                .frame(height: 100)
                

            }
            
            
            
            HStack {
                createTab("Battery", tag: "batt", $selectedPowermetrics)
                createTab("CPU", tag: "cpu", $selectedPowermetrics)
                createTab("GPU", tag: "gpu", $selectedPowermetrics)
                createTab("Memory", tag: "mem", $selectedPowermetrics)
                createTab("Processes", tag: "processes", $selectedPowermetrics)
            }
            .frame(minWidth: 300, maxWidth: 500)
                

            switch selectedPowermetrics {
            case "batt":  BatteryPowermetrics.environmentObject(model)
            case "cpu": CPUPowermetrics.environmentObject(model)
            case "gpu": GPUView.environmentObject(model)
            case "mem": MemoryPowermetrics.environmentObject(model)
            case "processes": ProcessesView.environmentObject(model)
            default: BatteryPowermetrics
            }
        }
        .windowPanelStyle("Powermetrics")

    }
    
    private func header() -> some View {
        return HStack {
            Text("Model Predictions")
                .padding(.vertical, 25)
                .font(.system(size: 18, weight: .bold))
            
            Image(systemName: "power.circle")
                .imageScale(.large)
                .foregroundStyle(Color.primary, Color.dataToColor(from: selectedColorData) ?? selectedAccentColor)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
}
