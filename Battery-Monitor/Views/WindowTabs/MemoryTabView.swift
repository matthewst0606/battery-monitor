//
//  MemoryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

struct MemoryPowermetricsView: View {
    @EnvironmentObject var model: PythonModelRunner

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ListItem(arg1: "Total Memory", arg2: String(format: "%.2fGB", result.usedMemory), arg3: .primary)
                    ListItem(arg1: "Used Memory", arg2: String(format: "%.2fGB", result.usedMemory), arg3: .primary)
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}

struct MemoryTabView: View {
    @EnvironmentObject var mem: MemoryService

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let memory = mem.info {
                    ListItem(arg1: "Total", arg2: String(format: "%.2f GB", memory.total), arg3: .primary)
                    ListItem(arg1: "Cached", arg2: String(format: "%.2f GB", memory.cached), arg3: .primary)

                    
                    switch memory.used {
                    case 0.0...10.0:  ListItem(arg1: "Used", arg2: String(format: "%.2f GB", memory.used), arg3: .green)
                    case 10.0...20.0: ListItem(arg1: "Used", arg2: String(format: "%.2f GB", memory.used), arg3: .yellow)
                    case 20.0...24.0: ListItem(arg1: "Used", arg2: String(format: "%.2f GB", memory.used), arg3: .orange)
                    default:          ListItem(arg1: "Used", arg2: String(format: "%.2f GB", memory.used), arg3: .red)
                    }
                    switch memory.available {
                    case 0.0...3.0: ListItem(arg1: "Available", arg2: String(format: "%.2f GB", memory.available), arg3: .red)
                    case 3.0...5.0: ListItem(arg1: "Available", arg2: String(format: "%.2f GB", memory.available), arg3: .orange)
                    case 5.0...7.0: ListItem(arg1: "Available", arg2: String(format: "%.2f GB", memory.available), arg3: .yellow)
                    default:        ListItem(arg1: "Available", arg2: String(format: "%.2f GB", memory.available), arg3: .green)
                    }
                    
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
    

}
