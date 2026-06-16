//
//  ProcessesTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI


struct ProcessesTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @EnvironmentObject var modelRunner: PythonModelRunner

    var body: some View {
        VStack(spacing: 5) {
            List {
                ListItem(arg1: "Number of Processes:", arg2: "\(modelRunner.numOfProcesses)")
                ListItem(arg1: "Process Power:", arg2: "\(modelRunner.processPower, default: "%.2f")")
                ListItem(arg1: "Running Processes:", arg2: "\(modelRunner.processState)")
            }
            .unscrollableListStyle()
        }
        .appTabStyle()
    }
}
