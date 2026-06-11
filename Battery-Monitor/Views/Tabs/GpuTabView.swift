//
//  GpuTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI


struct GpuTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("GPU Usage: \(Int())%")
            Text("GPU Frequency: \(Int()) MHz")
            Text("GPU Residency: \(Int())%")
            Text("GPU Idle: \(Int())%")
            Text("GPU Power: \(Int())")
        }
    }
}
