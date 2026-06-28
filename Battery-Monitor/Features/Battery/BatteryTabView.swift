//
//  BatteryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//
import SwiftUI
import Combine

// ----------------------------------------------------------
//  ===== Battery Powermetrics View in Powermetrics tab =====
//  ---------------------------------------------------------
struct BatteryPowermetricsView: View {
    @EnvironmentObject var model: ModelService
    
    var body: some View {
        VStack(spacing: 10) {
                
            List {
                if let result = model.result {modelSummary(for: result)}
            }
            .unscrollableListStyle()
            .frame(maxHeight: 120)
            .help("""
                    A summary of the models predictions. 
                    It updates relative to the selected time
                    interval located in settings
            """)
            
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

            }.scrollableListStyle()
            
        }.smallPanelStyle()
    }
    
    // -------------------------
    // ===== Summary =====
    // -------------------------
    private func modelSummary(for result: PythonResult) -> some View {
        VStack(alignment: .leading, spacing: 6) {
                Text("Summary")
                    .font(.system(size: 12, weight: .bold))
                Text("\(result.predictionSummary), \(result.drainRateDeltaText)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                Text("(Confidence: \(result.confidence?.level ?? "") \(result.confidence?.reason ?? ""))")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
    }
    
    // -------------------------
    // ===== Standard Rows =====
    // -------------------------
    private func listItems(for result: PythonResult) -> [MetricRow] {
        [
            MetricRow(
                title: "Current Battery Prediction",
                value: model.formatBatteryPrediction(result.timeRemaining),
                color: .primary
            ),
            MetricRow(
                title: "Drain Rate",
                value: result.drainRateText,
                color: .primary
            ),
            MetricRow(
                title: "Average Drain Rate",
                value: result.avgDrainRateText,
                color: .primary
            ),
        ]
    }
}




// ------------------------------------------
//  ===== Battery Tab View in Stats tab =====
//  -----------------------------------------
struct BatteryTabView: View {
    @EnvironmentObject var battery: BatteryService

    var body: some View {
        ChartMetricScope(
            refresh: battery.$info.map { _ in }.eraseToAnyPublisher()
        ) { chartMetrics in
            VStack(spacing: 5) {
                List {
                    if let battInfo = battery.info {
                        ForEach(listItems(for: battInfo)) { metric in
                            HeaderItem(
                                title: metric.title,
                                value: metric.value,
                                color: metric.color
                            )
                        }
                    }
                    else { LoadingScreen() }
                }
                .unscrollableListStyle()
                .frame(maxHeight: 110)
                
                
                List {
                    if let battInfo = battery.info {
                        ForEach(chartableItems(for: battInfo)) { metric in
                            chartMetrics.row(metric)
                        }

                    }
                }
                .scrollableListStyle()
                

            }
            .smallPanelStyle()
        }
    }
    
    // ---------------------------
    //  ===== Chartable Rows =====
    //  --------------------------
    private func chartableItems(for battInfo: BatteryInfo) -> [MetricRow] {
        [
            MetricRow(
                title: "Battery Level",
                value: "\(battInfo.batteryLevel)%",
                color: batteryLevelColor(
                    battInfo.batteryLevel,
                    powerSrc: battInfo.powerSourceState
                ),
                chart: .batteryLevel,
                visibilityKey: BatteryMenuKey.level

            ),
            MetricRow(
                title: "Battery Temperature",
                value: String(format: "%.2f ℃", battInfo.temperature),
                color: batteryTemperatureColor(battInfo.temperature),
                chart: .batteryTemperature,
                visibilityKey: BatteryMenuKey.temperature

            ),
            MetricRow(
                title: battInfo.powerSourceState == "AC Power" ? "Time to Full" : "Time Remaining",
                value: "\(battery.timeRemainingText)",
                color: timeRemainingColor(
                    Int(battInfo.timeRemaining),
                    battInfo.powerSourceState
                ),
                chart: .batteryTimeRemaining,
                visibilityKey: BatteryMenuKey.timeRemaining

            ),
        ]
    }
    
    // -------------------------
    // ===== Standard Rows =====
    // -------------------------
    private func listItems(for battInfo: BatteryInfo) -> [MetricRow] {
        [
            MetricRow(
                title: "Max Capacity",
                value: "\(battInfo.maxCapacity)%",
                color: .primary,
                visibilityKey: BatteryMenuKey.capacity
            ),
        
            MetricRow(
                title: "Power Source",
                value: "\(battInfo.powerSourceState)",
                color: .primary,
                visibilityKey: BatteryMenuKey.powerSource
            ),
        
            MetricRow (
                title: "Low Power Mode",
                value: battInfo.powerMode == 1 ? "On" : "Off",
                color: .primary,
                visibilityKey: BatteryMenuKey.lowPowerMode
            )
        ]
    }
    
    // -------------------------
    // ===== Text Coloring =====
    // -------------------------
    private func batteryLevelColor(_ percent: Int, powerSrc: String) -> Color {
        // plugged in
        if powerSrc == "AC Power" {
            switch percent {
            case 80...100: return .green
            case 50..<80:  return .primary
            case 20..<50:  return .yellow
            default:       return .orange
            }
        }

        // On battery
        switch percent {
        case 80...100: return .green
        case 50..<80:  return .primary
        case 30..<50:  return .yellow
        case 15..<30:  return .orange
        case 5..<15:   return .red
        default:       return .purple
        }
    }
    
    private func batteryTemperatureColor(_ celsius: Double) -> Color {
        switch celsius {
        case ..<0:    return .blue
        case 0..<10:  return .cyan
        case 10..<30: return .green
        case 30..<35: return .yellow
        case 35..<40: return .orange
        case 40..<45: return .red
        default:      return .purple
        }
    }
    
    private func timeRemainingColor(_ minutes: Int, _ powerSrc: String) -> Color {
        guard powerSrc != "AC Power" else { return .primary }
        guard minutes > 0 else { return .secondary }

        switch minutes {
        case 360...:     return .green      // 6+ hours
        case 180..<360:  return .primary    // 3–6 hours
        case 90..<180:   return .yellow     // 1.5–3 hours
        case 30..<90:    return .orange     // 30–90 min
        case 10..<30:    return .red        // 10–30 min
        default:         return .purple     // under 10 min
        }
    }
}
