//
//  BatteryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//
import SwiftUI
import Charts


struct BatteryTabView: View {
    @StateObject private var monitor = BatteryMonitor()
    @EnvironmentObject var modelRunner: PythonModelRunner
    @State private var out = ""
    
    @State var data: [timeRemaining] = []
    struct timeRemaining: Identifiable {
        let name: String
        let prediction: Double
        let timestamp: Date
        let id = UUID()
        
        init(name: String, prediction: Double) {
            self.name = name
            self.prediction = prediction
            self.timestamp = Date()
            _ = Calendar.autoupdatingCurrent
        }
    }


    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 5) {
            Text("Current Charge: \(Int(monitor.batteryLevel))%").widgetText()
            Text("Battery Health: \(monitor.batteryHealth)").widgetText()
            Text("Cycle Count: \(modelRunner.cycleCount)").widgetText()
            Text("Current Battery Prediction: \(Int(modelRunner.timeRemaining))").widgetText()
            
            
            
//            Chart(data) { cost in
//                AreaMark(
//                    x: .value("Date", cost.timestamp),
//                    y: .value("Price", cost.prediction)
//                )
//            }
            
        }
            .padding()
            .frame(width: 500, height: 500, alignment: .topLeading)
            .background(.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onChange(of: modelRunner.timeRemaining) {
                data.append(
                    timeRemaining(
                        name: "estimatedBattery",
                        prediction: modelRunner.timeRemaining
                    )
                )
            }
        


    }
        
        

}


