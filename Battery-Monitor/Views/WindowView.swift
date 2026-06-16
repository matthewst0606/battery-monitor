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
    @StateObject private var modelRunner = PythonModelRunner()
    
    @StateObject private var cpu = CPUService()
    @StateObject private var mem = MemoryService()

    @ViewBuilder private var BatteryPowermetrics: some View {BatteryPowermetricsView()}
    @ViewBuilder private var BatteryTab: some View {BatteryTabView().environmentObject(monitor)}
    
    @ViewBuilder private var CPUPowermetrics: some View {CPUPowermetricsView()}
    @ViewBuilder private var CPUTab: some View {CPUTabView().environmentObject(cpu)}
    
    @ViewBuilder private var MemoryPowermetrics: some View {MemoryPowermetricsView()}
    @ViewBuilder private var MemoryTab: some View {MemoryTabView().environmentObject(mem)}
    
    @ViewBuilder private var GPUView: some View {GpuTabView()}
    @ViewBuilder private var ProcessesView: some View {ProcessesTabView()}

    @State private var pythonOutput = ""
    @State private var selectedStat = "batt"
    @State private var pressedButton: String? = nil
    
    

    
    var ModelView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Epoch: \(Int())")
            Text("Model Prediction: \(Int())")
        }
    }
    

    
    
    var body: some View {
        TabView() {
            
            
            Tab("Stats", systemImage: "macbook.gen2") {
                    
                
                LazyVStack(alignment: .center, spacing: 10) {
                    LazyVStack {
                        Text("This Mac")
                            .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                            .font(.system(size: 18, weight: .bold))
                        
                        Image(systemName: "macbook.gen2")
                            .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                            .imageScale(.large)
                        
                        Text("Chip: ")
                        Text("Memory: \(mem.info!.total, specifier: "%.0f")GB")
                        Text("Version: \(ProcessInfo.processInfo.operatingSystemVersionString)")
                    }
                    .padding(20)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                    
                    
                    
                    HStack {
                        Button {
                            withAnimation(.easeInOut) { selectedStat = "batt" }
                        } label: {
                            Text("battery")
                                .widgetText()
                                .tabBarButtonAnimation(isSelected: selectedStat == "batt")
                        }
                        .tabBarButton(val: selectedStat)

                        Button {
                            withAnimation(.easeInOut)
                                { selectedStat = "cpu" }
                        } label: {
                            Text("CPU")
                                .widgetText()
                                .tabBarButtonAnimation(isSelected: selectedStat == "cpu")
                        }
                        .tabBarButton(val: selectedStat)




                        Button {
                            withAnimation(.easeInOut)
                            { selectedStat = "mem" }
                        } label: {
                            Text("Memory")
                                .widgetText()
                                .tabBarButtonAnimation(isSelected: selectedStat == "mem")
                        }
                        .tabBarButton(val: selectedStat)
                    }
                    .frame(width: 300)


                    switch selectedStat {
                        case "batt": BatteryTab
                        case "cpu": CPUTab
                        case "mem": MemoryTab
                        default: BatteryTab
                    }
                }
                .padding(20)
                .frame(width: 500)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
                

            
            
            
            
            
            
            
            Tab("Powermetrics", systemImage: "bolt.fill") {
                TabView {
                    Tab("Battery", systemImage: "") { BatteryPowermetrics.environmentObject(modelRunner) }
                    Tab("CPU", systemImage: "") { CPUPowermetrics.environmentObject(modelRunner) }
                    Tab("GPU", systemImage: "") { GPUView.environmentObject(modelRunner) }
                    Tab("Memory", systemImage: "") { MemoryPowermetrics.environmentObject(modelRunner) }
                    Tab("Processes", systemImage: "") { ProcessesView.environmentObject(modelRunner) }
                }
                .tabViewStyle(.grouped)
                .navigationTitle(Text("Powermetrics"))
            }
            
        
            
            Tab("Model Logs", systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill") {
                VStack {
                    GroupBox {
                        ScrollView {
                            Text(pythonOutput)
                                .widgetText()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                    }.padding()
                }
            }
            
            Tab("Other", systemImage: "info.circle.fill") {}
        }
        
        .tabViewStyle(.sidebarAdaptable)
        .background(.ultraThinMaterial)
        .onAppear() {
            pythonOutput = "Loading..."
            DispatchQueue.global(qos: .background).async {
                let result = modelRunner.getPy()
                DispatchQueue.main.async { pythonOutput = result }
            }
            

        }
        
    }
}
