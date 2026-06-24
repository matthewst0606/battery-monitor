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
    @EnvironmentObject private var battery: BatteryService
    @EnvironmentObject private var model: ModelService

    private var StatsTab: some View { StatsTabView() }
    private var ModelTab: some View { ModelTabView() }
    private var PowermetricsTab: some View { PowermetricsTabView() }
    private var OtherTab: some View { OtherTabView() }

    var body: some View {
        TabView() {
            Tab("Stats", systemImage: "macbook.gen2") { StatsTab }
            Tab("Powermetrics", systemImage: "bolt.fill") { PowermetricsTab }
            Tab("Model Logs", systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill") { ModelTab }
            Tab("Other", systemImage: "info.circle.fill") { OtherTab }
        }
        .background(.regularMaterial)
        .onAppear() {
            if !model.isRunningPython {
                model.updatePy(powerSourceState: battery.info?.powerSourceState)
            }
        }

    }
}
