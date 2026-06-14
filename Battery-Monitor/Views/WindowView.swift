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
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    
    @StateObject private var cpu = CPUService()
    @StateObject private var mem = MemoryService()

    @State private var pythonOutput = ""


    @ViewBuilder private var BatteryView: some View {BatteryTabView()}
    @ViewBuilder private var CPUView: some View {CpuTabView()}
    @ViewBuilder private var GPUView: some View {GpuTabView()}
    @ViewBuilder private var MemoryView: some View {MemoryTabView()}
    @ViewBuilder private var ProcessesView: some View {ProcessesTabView()}


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
                        Tab("Battery", systemImage: "") { BatteryView.environmentObject(modelRunner) }
                        Tab("CPU", systemImage: "") { CPUView.environmentObject(modelRunner) }
                        Tab("GPU", systemImage: "") { GPUView.environmentObject(modelRunner) }
                        Tab("Memory", systemImage: "") { MemoryView.environmentObject(modelRunner) }
                        Tab("Processes", systemImage: "") { ProcessesView.environmentObject(modelRunner) }
                    }
                    .tabViewStyle(.automatic)
                }
                
                Tab("Usage", systemImage: "bolt.fill") {
                    TabView {
                        Tab("Model Predictions", systemImage: " ") {
                            Text("Estimated Battery Left: ")
                            Text("Battery Loss per Hour: ")
                        }
                    }.tabViewStyle(.automatic)
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
                    VStack(spacing: 15) {
                        VStack {
                            Text("This Mac")
                                .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                            Image(systemName: "macbook.gen2")
                                .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                        }
                        .frame(width: 250, height: 75)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        
                        
                        VStack(spacing: 5) {
                            HStack {
                                Text("CPU")
                                Image(systemName: "cpu")
                            }


                            
                            if let info = cpu.info {
                                Text("Active Cores: \(info.activeCores, specifier: "%.2f")")
                                Text("Total Usage: \(info.total, specifier: "%.2f")%")
                                Text("User Usage: \(info.user, specifier: "%.2f")%")
                                Text("System Usage: \(info.sys, specifier: "%.2f")%")
                                Text("Idle: \(info.idle, specifier: "%.2f")%")
                            }
                        }
                        .frame(width: 250, height: 150)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        
                        
                        
                        
                        VStack {
                            HStack {
                                Text("Memory")
                                Image(systemName: "memorychip")
                            }
                            if let memory = mem.info {
                                Text("Test total: \(memory.total, specifier: "%.2f")GB")
                                Text("Test used: \(memory.used, specifier: "%.2f")GB")
                                Text("Test available: \(memory.available, specifier: "%.2f")GB")
                                Text("Test cached: \(memory.cached, specifier: "%.2f")GB")
                            }
                        }
                        .frame(width: 250, height: 150)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        

                        

                        
                        
                    }


                }
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
            

            monitor.update()
        }
        
    }
}

#Preview {
    WindowView()
}
