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
                else { loading() }

            }.unscrollableListStyle()
        }.appTabStyle()
    }
}


struct ProcessTabView: View {
    @EnvironmentObject var process: ProcessService

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Process")
                    .standard()
                    .frame(maxWidth: 150, alignment: .leading)

                Text("PID")
                    .standard()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Power")
                    .standard()
                    .frame(width: 70, alignment: .trailing)

                Text("State")
                    .standard()
                    .frame(width: 80, alignment: .trailing)
            }
            .standardPadding()
            
            List(process.processes) { p in
                HStack {
                    Text(p.command)
                        .frame(maxWidth: 150, alignment: .leading)
                        .foregroundStyle(stateColor(p.state, Double(p.power) ?? -1))

                    Text(p.pid)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(stateColor(p.state, Double(p.power) ?? -1))

                    Text(p.power)
                        .frame(width: 70, alignment: .trailing)
                        .foregroundStyle(stateColor(p.state, Double(p.power) ?? -1))


                    Text(p.state)
                        .frame(width: 80, alignment: .trailing)
                        .foregroundStyle(stateColor(p.state, Double(p.power) ?? -1))
                }
            }
            .scrollableListStyle()
            
            
        }.appTabStyle()
    }
    
    private func stateColor(_ value: String, _ power: Double) -> Color {
        switch value {
        case "sleeping": return powerColor(power).opacity(0.5)
        default: return .primary
        }
    }
    
    private func powerColor(_ value: Double) -> Color {
        switch value {
        case 100.0...: return .red
        case 50.0..<100.0: return .orange
        case 25.0..<50.0: return .yellow
        case 10.0..<25.0: return .primary
        default: return .primary.opacity(0.5)
        }
    }
}
