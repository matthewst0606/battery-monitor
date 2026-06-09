/*
    ContentView.swift
    ------------------
    displays a window when the menubar icon is clicked
    showing the battery percentage, time remaining on battery
    (or time remaining to full charge), and battery health.
    to access settings menu from this window, press cmd + ,
 
    Created by Matt on 5/28/26.
*/
import SwiftUI
import IOKit.ps


struct MenuBarView: View {
    @StateObject private var monitor = BatteryMonitor()
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor
    @State private var pythonOutput = ""
    
    private var batteryIconView: some View {
        ZStack {
            Image(systemName: "\(monitor.batteryIcon)")
                .font(.system(size: 30, weight: .light))
                .imageScale(.medium)
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    Color.dataToColor(from: selectedColorData) ?? selectedAccentColor,
                    Color.primary
                )

            Text("\(Int(monitor.batteryLevel))%")
                .offset(x: -1.5)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)

            Text(pythonOutput)
            
        }
    }
    
    // returns a string that displays how long it will take until
    // battery is dead or fully charged
    private var timeRemainingText: String {
        if monitor.isCharging {
            if monitor.timeToFullBattery == -1.0
                { return "calculating" }
            return "Time to Full: \(monitor.timeToFullBattery)"
        }
        else {
            if monitor.calculateTimeRemaining() == "0:0-1"
                { return "calculating" }
            return "\(monitor.calculateTimeRemaining())"
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            // run batteryIconView to display icon with battery level
            batteryIconView
            
            // display time remaining and battery health
            GroupBox {
                Text("Time Remaining: \(timeRemainingText)")
                    .widgetText()
                Text("Battery Health: \(monitor.batteryHealth)")
                    .widgetText()
            }
        }
        .padding()
        .onAppear {
            monitor.update()
        }
    }
}

#Preview { MenuBarView() }
