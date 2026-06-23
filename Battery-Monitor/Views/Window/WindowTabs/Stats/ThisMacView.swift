//
//  ThisMacView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/23/26.
//
import SwiftUI

struct ThisMacView: View {
    @EnvironmentObject private var monitor: BatteryService
    @EnvironmentObject private var cpu: CPUService
    @EnvironmentObject private var mem: MemoryService

    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor
    
    var body: some View {
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
}
