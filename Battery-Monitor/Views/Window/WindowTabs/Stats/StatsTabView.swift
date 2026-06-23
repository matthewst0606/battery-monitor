//
//  StatsTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/23/26.
//
import SwiftUI



struct StatsTabView: View {
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor
    @State private var selectedStat = "batt"

    
    // stats page tabs
    private var CPUTab: some View { CPUTabView() }
    private var MemoryTab: some View { MemoryTabView() }
    private var BatteryTab: some View { BatteryTabView() }
    private var ProcessTab: some View { ProcessTabView() }
    private var ThisMac: some View { ThisMacView() }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ThisMac
            
            HStack {
                createTab(title: "Battery", tag: "batt", selectedStat: $selectedStat)
                createTab(title: "CPU", tag: "cpu", selectedStat: $selectedStat)
                createTab(title: "Memory", tag: "mem", selectedStat: $selectedStat)
                createTab(title: "Process", tag: "process", selectedStat: $selectedStat)
            }
            .frame(minWidth: 300, maxWidth: 500)


            switch selectedStat {
            case "batt":    BatteryTab
            case "cpu":     CPUTab
            case "mem":     MemoryTab
            case "process": ProcessTab
            default:        BatteryTab
            }
        }
        .windowTabStyle(title: "Stats")
    }
}
