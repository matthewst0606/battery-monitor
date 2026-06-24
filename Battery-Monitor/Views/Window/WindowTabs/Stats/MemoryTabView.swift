//
//  MemoryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI

struct MemoryPowermetricsView: View {
    @EnvironmentObject var model: ModelService

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ListItem(arg1: "Total Memory", arg2: String(format: "%.2fGB", result.totalMemory), arg3: .primary)
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
                    ListItem(arg1: "Total Memory", arg2: String(format: "%.2f GB", memory.total), arg3: .primary)
                    ListItem(arg1: "Cached Memory", arg2: String(format: "%.2f GB", memory.cached), arg3: .primary)

                    
                    switch memory.used {
                    case 0.0...10.0:  ListItem(arg1: "Used Memory", arg2: String(format: "%.2f GB", memory.used), arg3: .green)
                    case 10.0...20.0: ListItem(arg1: "Used Memory", arg2: String(format: "%.2f GB", memory.used), arg3: .yellow)
                    case 20.0...24.0: ListItem(arg1: "Used Memory", arg2: String(format: "%.2f GB", memory.used), arg3: .orange)
                    default:          ListItem(arg1: "Used Memory", arg2: String(format: "%.2f GB", memory.used), arg3: .red)
                    }
                    switch memory.available {
                    case 0.0...3.0: ListItem(arg1: "Available Memory", arg2: String(format: "%.2f GB", memory.available), arg3: .red)
                    case 3.0...5.0: ListItem(arg1: "Available Memory", arg2: String(format: "%.2f GB", memory.available), arg3: .orange)
                    case 5.0...7.0: ListItem(arg1: "Available Memory", arg2: String(format: "%.2f GB", memory.available), arg3: .yellow)
                    default:        ListItem(arg1: "Available Memory", arg2: String(format: "%.2f GB", memory.available), arg3: .green)
                    }
                    
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
    

}

struct MemoryMenuView: View {
    @State private var test: Bool = true

    var body: some View {
        Toggle("Total Memory", isOn: $test)
        Toggle("Cached Memory", isOn: $test)
        Toggle("Used Memory", isOn: $test)
        Toggle("Available Memory", isOn: $test)
    }
}
