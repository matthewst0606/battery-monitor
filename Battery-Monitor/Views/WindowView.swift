//
//  WindowView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI
import AppKit

struct WindowView: View {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    @State private var pythonOutput = ""


    @ViewBuilder private var BatteryView: some View {BatteryTabView()}
    @ViewBuilder private var CPUView: some View {CpuTabView()}
    @ViewBuilder private var GPUView: some View {GpuTabView()}
    @ViewBuilder private var MemoryView: some View {CpuTabView()}
    @ViewBuilder private var ProcessesView: some View {CpuTabView()}


    var ModelView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Epoch: \(Int())")
            Text("Model Prediction: \(Int())")
            
            
        }
    }
    
    
    var body: some View {
        VStack {

            TabView() {
                Tab("Stats", systemImage: "macbook.gen2") {
                    TabView {
                        Tab("Battery", systemImage: "bolt.fill") { BatteryView }
                        Tab("CPU", systemImage: "") { CPUView }
                        Tab("GPU", systemImage: "") { GPUView }
                        Tab("Memory", systemImage: "") { MemoryView }
                        Tab("Processes", systemImage: "") { ProcessesView }
                    }
                    .tabViewStyle(.automatic)
                }
                
                Tab("Usage", systemImage: "bolt.fill") {
                    
                    
                }
                
                Tab("Model", systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill") {
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
        }
        .tabViewStyle(.sidebarAdaptable)
        .onAppear() {
            pythonOutput = "Loading..."
            DispatchQueue.global(qos: .background).async {
                let result = modelRunner.getPy()
                DispatchQueue.main.async { pythonOutput = result }
            }
            
            monitor.update()
        }
        
    }
}

#Preview {
    WindowView()
}
