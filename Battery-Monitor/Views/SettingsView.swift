import SwiftUI
import AppKit




struct SettingsView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @EnvironmentObject var model: ModelService
    @EnvironmentObject var cpu: CPUService

    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var colorPickerColor: Color = .blue
    
    
    private var CustomizeTab: some View { CustomizeTabView() }
    private var GeneralTab: some View { GeneralTabView() }

    var body: some View {
        // create the tabs that are displayed
        // at the top of the settings page
        TabView {
            GeneralTab.tabItem {
                Image(systemName: "gearshape")
                    .environmentObject(monitor)
            }.tag(1)
            
            CustomizeTab.tabItem {
                Image(systemName: "square.and.pencil.circle.fill")
            }.tag(2)
        }
        .onAppear() {
            if let color = Color.dataToColor(from: selectedColorData) {
                colorPickerColor = color
            }
        }
    }
}

