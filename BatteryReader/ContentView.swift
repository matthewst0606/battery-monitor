//
//  ContentView.swift
//
//  Created by Matt on 5/28/26.
//
import SwiftUI
import IOKit.ps




struct ContentView: View {
    @StateObject private var monitor = BatteryMonitor()
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor
    
    
    
    
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
        }
    }
    
    private var timeRemainingText: String {
        if monitor.isCharging { return "Time to Full: \(monitor.timeToFullBattery)" }
        else { return "Time Remaining: \(monitor.calculateTimeRemaining())" }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            batteryIconView
            
            GroupBox {
                Text(timeRemainingText)
                    .widgetText()
                
                Text("Battery Health: \(monitor.batteryHealth)")
                    .widgetText()
            }
        }
        .onAppear() {monitor.update()}
    }
}

#Preview { ContentView() }
