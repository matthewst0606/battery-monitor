//
//  MemoryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

struct MemoryPowermetricsView: View {
    @EnvironmentObject var modelRunner: PythonModelRunner

    var body: some View {
        VStack(spacing: 5) {
            List {
                ListItem(arg1: "Total Memory", arg2: String(format: "%.2fGB", modelRunner.usedMemory))
                ListItem(arg1: "Used Memory", arg2: String(format: "%.2fGB", modelRunner.usedMemory))
            }
            .unscrollableListStyle()
        }
        .appTabStyle()
    }

    
}


struct MemoryTabView: View {
    @EnvironmentObject var mem: MemoryService

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let memory = mem.info {
                    ListItem(arg1: "Total", arg2: String(format: "%.2f GB", memory.total))
                    ListItem(arg1: "Used", arg2: String(format: "%.2f GB", memory.used))
                    ListItem(arg1: "Available", arg2: String(format: "%.2f GB", memory.available))
                    ListItem(arg1: "Cached", arg2: String(format: "%.2f GB", memory.cached))

                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
    

}
