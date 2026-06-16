//
//  BatteryTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/11/26.
//
import SwiftUI
import Charts


struct BatteryPowermetricsView: View {
    @EnvironmentObject var monitor: BatteryMonitor
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
            Text("Current Charge: \(Int(monitor.info?.batteryLevel ?? 0))%").widgetText()
            Text("Battery Health: \(monitor.info?.batteryHealth ?? 0)").widgetText()
            Text("Cycle Count: \(modelRunner.cycleCount)").widgetText()
            Text("Current Battery Prediction: \(Int(modelRunner.timeRemaining))").widgetText()
            
            
            
            Chart(data) { i in
                AreaMark(
                    x: .value("Date", i.timestamp),
                    y: .value("Prediction", i.prediction)
                )
            }
            
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


struct BatteryTabView: View {
    @EnvironmentObject var monitor: BatteryMonitor

    var body: some View {
        VStack(spacing: 5) {

            HStack {
                Text("Battery").widgetText()
                Image(systemName: "battery.100").imageScale(.medium)
            }
            List {
                if let battInfo = monitor.info {
                    HStack {
                        Text("Battery Level:").ListText()
                        Spacer()
                        Text("\(battInfo.batteryLevel)%").ListText()

                    }
                    
                    HStack {
                        Text("Battery Health:").ListText()
                        Spacer()
                        Text("\(battInfo.batteryHealth)%").ListText()
                    }
                    
                    HStack {
                        Text("Is Device Charging:").ListText()
                        Spacer()
                        Text("\(battInfo.isCharging ? "yes" : "no")").ListText()
                    }
                    
                    HStack {
                        Text("Time Remaining:").ListText()
                        Spacer()
                        Text("\(monitor.timeRemainingText)").ListText()
                    }
                    

                }
            }
            .unscrollableListStyle()


        }
        .appTabStyle()
    }

}


