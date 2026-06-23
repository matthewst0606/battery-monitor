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
    @EnvironmentObject var monitor: BatteryMonitor
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    
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
            Text("\(monitor.info?.batteryLevel ?? 0)%")
                .offset(x: -1.5)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
        }
    }
    

    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // run batteryIconView to display icon with battery level
            batteryIconView

            // display time remaining and battery health
            GroupBox {
                Text("Time Remaining: \(monitor.timeRemainingText)").widgetText()
                Text("Battery Health: \(monitor.info?.batteryHealth ?? 0)").widgetText()
            }
            
            HStack {
                Button { openWindow(id: "main") }
                label: {
                    Image(systemName: "macwindow")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary, Color.dataToColor(from: selectedColorData) ?? selectedAccentColor)
                }
                .frame(width: 25, height: 15)
                .padding()
                .buttonStyle(.glass)

                
                Button { openSettings() }
                label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.dataToColor(from: selectedColorData) ?? selectedAccentColor)
                }
                .frame(width: 25, height: 15)
                .padding()
                .buttonStyle(.glass)

            }
        }
        .padding(EdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5))
        .frame(width: 200, height: 175)
    }
}

