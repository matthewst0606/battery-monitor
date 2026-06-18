import SwiftUI
import AppKit


@main
struct MainApp: App {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    @StateObject var mem =  MemoryService()
    @StateObject private var cpu = CPUService()
    
    @State private var settings = SettingsView()
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor
    
    @AppStorage("selectedMode") var selectedMode: Mode = .system
    @AppStorage("selectedFormat") var selectedFormat: menubarFormat = .regular
    
    private var colorScheme: ColorScheme? {
        switch selectedMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    

    var body: some Scene {
        WindowGroup("Battery Monitor", id: "main") {
            WindowView()
                .preferredColorScheme(colorScheme)
                .background(.bar)
                .environmentObject(monitor)
                .environmentObject(modelRunner)
                .environmentObject(cpu)
                .environmentObject(mem)

        }
        
        
        
        MenuBarExtra {
            MenuBarView()
                .background(.clear.opacity(0.2))
                .preferredColorScheme(colorScheme)
                .environmentObject(monitor)

                
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
                if selectedFormat == .regular {
                    Text("\(monitor.calculateTimeRemainingCompact())")
                        .font(.system(size: 10, weight: .thin,))
                        .foregroundStyle(.white)
                }
            }
        }
        .menuBarExtraStyle(.window)
        

        
        #if os(macOS)
        Settings {
            SettingsView()
                .frame(minWidth: 300, maxWidth: 500, minHeight: 500, maxHeight: 1000)
                .preferredColorScheme(colorScheme)
                .environmentObject(monitor)
                .environmentObject(cpu)
                .environmentObject(mem)

        }
        .windowResizability(.automatic)
        #endif

    }
}



