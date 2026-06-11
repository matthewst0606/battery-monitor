//
//  CpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI


struct CpuTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("CPU Usage: \(Int())%")
            Text("CPU Frequency: \(Int()) MHz")
            Text("CPU Residency: \(Int())%")
            Text("CPU Idle: \(Int())%")
            Text("CPU Power: \(Int())")

        }
    }
}
