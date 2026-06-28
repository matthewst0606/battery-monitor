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
import Combine

struct WindowView: View {
    @EnvironmentObject private var battery: BatteryService
    @EnvironmentObject private var model: ModelService

    
    private var StatsTab: some View { StatsTabView() }
    private var ModelTab: some View { ModelTabView() }
    private var PowermetricsTab: some View { PowermetricsTabView() }

    var body: some View {
        TabView() {
            Tab("Stats", systemImage: "macbook.gen2") { StatsTab }
            Tab("Powermetrics", systemImage: "bolt.fill") { PowermetricsTab }
            Tab("Model Logs", systemImage: "power.circle") { ModelTab }
        }
        .background(.regularMaterial)
        .onAppear() {
            if !model.isRunningPython {
                model.updatePy(powerSourceState: battery.info?.powerSourceState)
            }
        }
    }
}
