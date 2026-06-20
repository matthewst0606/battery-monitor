//
//  ProcessesTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//

import SwiftUI


struct ProcessesTabView: View {
    @EnvironmentObject var model: PythonModelRunner

    var body: some View {
        VStack(spacing: 5) {
            List {
                if let result = model.result {
                    ListItem(arg1: "Number of Processes:", arg2: "\(result.numOfProcesses)", arg3: .primary)
                    ListItem(arg1: "Process Power:", arg2: "\(result.processPower, default: "%.2f")", arg3: .primary)
                    ListItem(arg1: "Running Processes:", arg2: "\(result.processState)", arg3: .primary)
                }
            }.unscrollableListStyle()
        }.appTabStyle()
    }
}
