//
//  GeneralTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/17/26.
//
import SwiftUI

enum Mode: String, CaseIterable, Identifiable {
    case system, dark, light
    var id: Self { self }
}

enum menubarFormat: String, CaseIterable, Identifiable {
    case regular, compact
    var id: Self {self}
}

enum UpdateInterval: Int, CaseIterable, Identifiable {
    case one=1, two=2, three=3, five=5, ten=10
    var id: Self {self}
    
    var label: String {
        switch self {
            case .one: return "1s"
            case .two: return "2s"
            case .three: return "3s"
            case .five: return "5s"
            case .ten: return "10s"
        }
    }
}

enum PowermetricsInterval: Int, CaseIterable, Identifiable {
    case fifteen=15, thirty=30, sixty=60
    var id: Self {self}
    
    var label: String {
        switch self {
            case .fifteen: return "15s"
            case .thirty: return "30s"
            case .sixty: return "60s"
        }
    }
}




// creates the elements of the general tab in settings
struct GeneralTabView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @EnvironmentObject var cpu: CPUService
    @EnvironmentObject var mem: MemoryService
    
    @AppStorage("selectedMode") var selectedMode: Mode = .system
    @AppStorage("selectedFormat") var selectedFormat: menubarFormat = .regular
    @AppStorage("selectedUpdateInterval") var selectedUpdateInterval: UpdateInterval = .five
    @AppStorage("selectedPowermetricsInterval") var selectedPowermetricsInterval: PowermetricsInterval = .thirty
    
    @State private var colorPickerColor: Color = .blue
    @State private var menuBarBattery = true
    @State private var enableAutoAdjust = false
    
    private let serviceHelper = ServiceHelper()
    
    
    var body: some View {
        VStack(alignment: .center) {
            List {
                Picker("Appearance", selection: $selectedMode) {
                    Text("System").tag(Mode.system)
                    Text("Dark").tag(Mode.dark)
                    Text("Light").tag(Mode.light)
                }.padding()
                
                Picker("Menubar Format", selection: $selectedFormat) {
                    Text("Default").tag(menubarFormat.regular)
                    Text("Compact").tag(menubarFormat.compact)
                }.padding()
                
                Picker("Update Interval", selection: $selectedUpdateInterval) {
                    ForEach(UpdateInterval.allCases) { interval in
                        Text(interval.label).tag(interval)
                    }
                    
                }.padding()
                
                Picker("Powermetrics Interval", selection: $selectedPowermetricsInterval) {
                    ForEach(PowermetricsInterval.allCases) { interval in
                        Text(interval.label).tag(interval)
                    }
                    
                }.padding()
                
                Toggle("Show in Menubar", isOn: $menuBarBattery)
                    .padding()
                    .toggleStyle(.switch)
                
                Toggle("Enable Auto Adjust", isOn: $enableAutoAdjust)
                    .padding()
                    .toggleStyle(.switch)
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .background(.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
            
                // quit button
            Button { NSApp.terminate(nil) }
            label: {
                Text("Quit App")
                    .foregroundStyle(.primary)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.capsule)
            .padding()
        }
        .onChange(of: selectedUpdateInterval) {
            serviceHelper.createTimer {
                cpu.info = cpu.getProcessorInfo()
                mem.info = mem.getMemoryInfo()
                monitor.info = monitor.getBatteryInfo()
            }
        }
    }
    
}



