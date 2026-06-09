import SwiftUI
import AppKit


@main
struct MainApp: App {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor
    
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .background(.clear.opacity(0.2))
                .padding(17)
        }
        
        label: {
            HStack {
                Image(systemName: monitor.batteryIcon)
                    .font(.system(size: 16, weight: .medium))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        Color.dataToColor(from: selectedColorData) ?? selectedAccentColor,
                        Color.primary
                    )
              
                    Text("\(monitor.calculateTimeRemainingCompact())")
                        .font(.system(size: 10, weight: .thin,))
                        .foregroundStyle(.white)
                
            }
        }
        .menuBarExtraStyle(.window)
        .windowStyle(.hiddenTitleBar)
        
      
        #if os(macOS)
        Settings {
            SettingsView()
                .background(.clear.opacity(0.2))
        }
        #endif

    }
  
  
}


