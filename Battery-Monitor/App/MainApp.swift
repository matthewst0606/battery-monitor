import SwiftUI
import AppKit


@main
struct MainApp: App {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var model = ModelService()
    @StateObject var mem =  MemoryService()
    @StateObject private var cpu = CPUService()
    
    @State private var settings = SettingsView()
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor
    
    @AppStorage("selectedMode") var selectedMode: Mode = .system
    @AppStorage("selectedFormat") var selectedFormat: menubarFormat = .regular
    @AppStorage("menuBarBattery") private var menuBarBattery = true
    @AppStorage("inMenuBar") var inMenuBar: ShowInMenuBar = .timeRemaining

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
                .frame(minWidth: 550, idealWidth: 550, maxWidth: 550)
                .frame(minHeight: 700, idealHeight: 700, maxHeight: 700)
                .preferredColorScheme(colorScheme)
                .environmentObject(monitor)
                .environmentObject(model)
                .environmentObject(cpu)
                .environmentObject(mem)
        }
        .defaultSize(width: 550, height: 700)
        .windowResizability(.contentSize)
        
        
        MenuBarExtra(isInserted: $menuBarBattery) {
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
                    switch inMenuBar {
                    case .timeRemaining:
                        Text("\(monitor.calculateTimeRemainingCompact())")
                            .font(.system(size: 10, weight: .thin,))
                            .foregroundStyle(.white)
                    case .batteryPercent:
                        Text("\(monitor.info?.batteryLevel ?? 0)%")
                            .font(.system(size: 10, weight: .thin,))
                            .foregroundStyle(.white)
                    case .cycleCount:
                        Text("\(monitor.info?.cycleCount ?? 0)")
                            .font(.system(size: 10, weight: .thin,))
                            .foregroundStyle(.white)
                    }

                }
            }
        }
        .menuBarExtraStyle(.window)
        
        
        
        #if os(macOS)
        Settings {
            SettingsView()
                .frame(minWidth: 550, maxWidth: 550, minHeight: 550, maxHeight: 550)
                .preferredColorScheme(colorScheme)
                .environmentObject(monitor)
                .environmentObject(model)
                .environmentObject(cpu)
                .environmentObject(mem)
        }
        .windowResizability(.automatic)
        #endif

    }
}



