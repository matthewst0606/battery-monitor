//
//  ProcessesTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI


struct ProcessesTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Top Processes: \(Int())")
            Text("Number of Processes: \(Int())")
            Text("Process Power: \(Int())")
            Text("Running Processes: \(Int())")

        }
    }
}
