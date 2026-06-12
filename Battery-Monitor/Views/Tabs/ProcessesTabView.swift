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
        VStack(alignment: .leading, spacing: 5) {
            GroupBox {
                Text("Top Processes: \(-1)").widgetText()
                Text("Number of Processes: \(modelRunner.numOfProcesses)").widgetText()
                Text("Process Power: \(modelRunner.processPower, specifier: "%.2f")").widgetText()
                Text("Running Processes: \(modelRunner.processState)").widgetText()
            }
        }
    }
}
