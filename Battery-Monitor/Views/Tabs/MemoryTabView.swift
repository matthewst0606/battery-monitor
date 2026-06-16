//
//  MemoryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

struct MemoryPowermetricsView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @EnvironmentObject var modelRunner: PythonModelRunner

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            GroupBox {
                Text("Total Memory: \(modelRunner.totalMemory, specifier: "%.2f") GB").widgetText()
                Text("Used Memory: \(modelRunner.usedMemory, specifier: "%.2f") GB").widgetText()
            }
        }
    }
}


struct MemoryTabView: View {
    @EnvironmentObject var mem: MemoryService

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Memory").font(.system(size: 14, weight: .bold))
                Image(systemName: "memorychip").imageScale(.large)
            }
            
            List {
                if let memory = mem.info {
                    HStack {
                        Text("Total:").ListText()
                        Spacer()
                        Text("\(memory.total, specifier: "%.2f")GB").ListText()
                    }
                    HStack {
                        Text("Used:").ListText()
                        Spacer()
                        Text("\(memory.used, specifier: "%.2f")GB").ListText()
                    }
                    HStack {
                        Text("Available:").ListText()
                        Spacer()
                        Text("\(memory.available, specifier: "%.2f")GB").ListText()
                    }
                    HStack {
                        Text("Cached:").ListText()
                        Spacer()
                        Text("\(memory.cached, specifier: "%.2f")GB").ListText()
                    }
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
    

}
