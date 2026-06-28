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
                    ForEach(listItems(for: result)) { metric in
                        ListItem(
                            title: metric.title,
                            value: metric.value,
                            color: metric.color
                        )
                    }
                }
                else { LoadingScreen() }

            }.unscrollableListStyle()
        }.smallPanelStyle()
    }
    
    // -------------------------
    // ===== Standard Rows =====
    // -------------------------
    private func listItems(for result: PythonResult) -> [MetricRow] {
        [
            MetricRow(
                title: "Number of Processes",
                value: "\(result.numOfProcesses)",
                color: .primary,
            ),
            MetricRow(
                title: "Process Power",
                value: "\(result.processPower, default: "%.2f")",
                color: .primary,
            ),
            MetricRow(
                title: "Running Processes",
                value: "\(result.processState)",
                color: .primary,
            ),
        ]
        
    }
}


struct ProcessTabView: View {
    @EnvironmentObject var process: ProcessService

    var body: some View {
        VStack(spacing: 5) {
            processHeader()
            
            List(process.processes) { p in
                processBody(process: p)
            }
            .scrollableListStyle()
            
            
        }.smallPanelStyle()
    }
    
    private func processHeader() -> some View {
        return HStack {
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
        .background(.quinary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(height:25)
        .padding(.vertical, 10)


    }
    
    private func processBody(process: RunningProcess) -> some View {
        return HStack {
            let power = Double(process.power) ?? -1
            
            Text(process.command)
                    .frame(maxWidth: 150, alignment: .leading)
                    .foregroundStyle(stateColor(process.state, power))
            
            Text(process.pid)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(stateColor(process.state, power))
            
            Text(process.power)
                .frame(width: 70, alignment: .trailing)
                .foregroundStyle(stateColor(process.state, power))
            
            Text(process.state)
                .frame(width: 80, alignment: .trailing)
                .foregroundStyle(stateColor(process.state, power))
            
        }
    }
    
    private func stateColor(_ value: String, _ power: Double) -> Color {
        switch value {
        case "sleeping": return powerColor(power).opacity(0.5)
        default:         return powerColor(power)
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
