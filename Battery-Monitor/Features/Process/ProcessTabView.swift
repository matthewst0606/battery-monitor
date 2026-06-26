//
//  ProcessesTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI


struct ProcessesTabView: View {
    @EnvironmentObject var model: ModelService

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ListItem("Number of Processes:", value: "\(result.numOfProcesses)", color: .primary)
                    ListItem("Process Power:", value: "\(result.processPower, default: "%.2f")", color: .primary)
                    ListItem("Running Processes:", value: "\(result.processState)", color: .primary)
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}


struct ProcessTabView: View {
    @EnvironmentObject var process: ProcessService

    var body: some View {
        VStack(spacing: 5) {
            List(process.processes) { p in
                HStack {
                    Text(p.command)
                    Spacer()
                    Text(p.power)
                }
            }
            
        }.appTabStyle()
    }
}
