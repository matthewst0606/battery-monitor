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

    @State private var selectedStat = "batt"
    @State private var selectedPowermetrics = "batt"
    
    // powermetrics page tabs
    private var BatteryPowermetrics: some View {
        BatteryPowermetricsView()
            .environmentObject(model)
    }
    private var CPUPowermetrics: some View {
        CPUPowermetricsView()
            .environmentObject(model)
    }
    private var MemoryPowermetrics: some View {
        MemoryPowermetricsView()
    }
    private var GPUView: some View {
        GpuTabView()
            .environmentObject(model)
    }
    private var ProcessesView: some View {
        ProcessesTabView()
            .environmentObject(model)
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
            

    
        }
        .padding(.vertical, 10)
        .frame(minWidth: 300, maxWidth: 500)
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
            case "batt":  BatteryPowermetrics.environmentObject(model)
            case "cpu": CPUPowermetrics.environmentObject(model)
            case "gpu": GPUView.environmentObject(model)
            case "mem": MemoryPowermetrics.environmentObject(model)
            case "processes": ProcessesView.environmentObject(model)
            default: BatteryPowermetrics
            }
        }

    }
    
}
