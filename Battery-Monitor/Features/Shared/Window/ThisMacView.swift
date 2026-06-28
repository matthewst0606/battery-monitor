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
    
    @Binding var selectedStat: String

    
    var body: some View {
        VStack {
            List {
                header()
                
                ForEach(listHeaderItems(), id: \.title) { item in
                    HeaderItem(
                        title: item.title,
                        value: item.value,
                        color: item.color
                    )
                }
            }
            .unscrollableListStyle()
            .frame(height: 175) 
        }
    }
    
    private func header() -> some View {
        return HStack {
            Text("This Mac")
                .padding(EdgeInsets(top: 2, leading: 0, bottom:  5, trailing: 0))
                .font(.system(size: 18, weight: .bold))
            
            Image(systemName: "macbook.gen2")
                .padding(EdgeInsets(top: 2, leading: 0, bottom:  2, trailing: 0))
                .imageScale(.large)
                .foregroundStyle(Color.primary, Color.dataToColor(from: selectedColorData) ?? selectedAccentColor)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparator(.hidden)
    }
    
    private func listHeaderItems() -> [MetricRow] {
        [
            MetricRow(
                title:"Chip",
                value: "\(cpu.getChipName())",
                color: .primary
            ),
            MetricRow(
                title:"Memory",
                value: "\(Int(mem.info!.total)) GB",
                color: .primary
            ),
            MetricRow(
                title:"Version",
                value: "\(ProcessInfo.processInfo.operatingSystemVersionString)",
                color: .primary
            ),
            MetricRow(
                title:"System Uptime",
                value: monitor.formatHMS(monitor.info!.uptime),
                color: .primary
            )
        ]
    }
}
