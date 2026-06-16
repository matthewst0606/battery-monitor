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
    @State private var selectedPowermetrics = "batt"

    @State private var pressedButton: String? = nil
    
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor

    
    var ModelView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Epoch: \(Int())")
            Text("Model Prediction: \(Int())")
        }
    }
    
    func getChipName() -> String {
        var size: size_t = 0

        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var cpu = [CChar](repeating: 0, count: size)

        sysctlbyname("machdep.cpu.brand_string", &cpu, &size, nil, 0)
        return String(cString: cpu)

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
                            .foregroundStyle(Color.primary, Color.dataToColor(from: selectedColorData) ?? selectedAccentColor)

                            List {
                                ListItem(arg1: "Chip", arg2: "\(getChipName())")
                                ListItem(arg1: "Memory", arg2: "\(Int(mem.info!.total)) GB")
                                ListItem(arg1: "Version", arg2: "\(ProcessInfo.processInfo.operatingSystemVersionString)")
                            }
                            .listStyle(.plain)
                            .scrollDisabled(true)
                            .frame(width: 400, height: 100)
                    }
                    .padding(10)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

        
                    
                    HStack {
                        createTab(title: "Battery", tag: "batt", selectedStat: $selectedStat)
                        createTab(title: "CPU", tag: "cpu", selectedStat: $selectedStat)
                        createTab(title: "Memory", tag: "mem", selectedStat: $selectedStat)
                    }
                    .frame(minWidth: 300)


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
            }
                

            

            Tab("Powermetrics", systemImage: "bolt.fill") {
                LazyVStack(alignment: .center, spacing: 10) {
                    HStack {
                        createTab(title: "Battery", tag: "batt", selectedStat: $selectedPowermetrics)
                        createTab(title: "CPU", tag: "cpu", selectedStat: $selectedPowermetrics)
                        createTab(title: "GPU", tag: "gpu", selectedStat: $selectedPowermetrics)
                        createTab(title: "Memory", tag: "mem", selectedStat: $selectedPowermetrics)
                        createTab(title: "Processes", tag: "processes", selectedStat: $selectedPowermetrics)
                    }
                    .padding(20)
                    .frame(minWidth: 500, maxHeight: .infinity, alignment: .top)
                    .background(.bar)

                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .navigationTitle(Text("Powermetrics"))
                    
                    
                    switch selectedPowermetrics {
                        case "batt":  BatteryPowermetrics.environmentObject(modelRunner)
                        case "cpu": CPUPowermetrics.environmentObject(modelRunner)
                        case "gpu": GPUView.environmentObject(modelRunner)
                        case "mem": MemoryPowermetrics.environmentObject(modelRunner)
                        case "processes": ProcessesView.environmentObject(modelRunner)
                        
                        default: BatteryPowermetrics
                    }
                }
                .frame(minWidth: 600, maxHeight: .infinity, alignment: .top)
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
            
            
            Tab("Other", systemImage: "info.circle.fill") {
                
                
            }
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
