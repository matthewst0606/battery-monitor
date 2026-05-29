import SwiftUI
import AppKit

@main
struct BatteryReaderApp: App {
    @StateObject private var monitor = BatteryMonitor()


  
  
    var body: some Scene {
      MenuBarExtra {
        ContentView()
      }
      label: {
          ZStack {
              Image(systemName: monitor.batteryIcon)
                  .font(.system(size: 16, weight: .medium))
                  .symbolRenderingMode(.palette)
                  .foregroundStyle(Color.accentColor, Color.primary)

            
            Text("\(monitor.calculateTimeRemaining())")
                .font(.system(size: 12, weight: .thin,))
                .foregroundStyle(.white)
                .padding()
          }
        
        
      }
        .menuBarExtraStyle(.window)
        .windowStyle(.hiddenTitleBar)
    }
  
  
}


