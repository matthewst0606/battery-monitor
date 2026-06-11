//
//  MemoryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI


struct MemoryTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Total Memory: \(Int())")
            Text("Used Memory: \(Int())")
        }
    }
}
