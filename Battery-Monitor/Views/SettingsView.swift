import SwiftUI
import AppKit




struct SettingsView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @EnvironmentObject var cpu: CPUService
    
    @ViewBuilder private var CustomizeTab: some View {CustomizeTabView()}
    @ViewBuilder private var GeneralTab: some View {GeneralTabView()}

    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var colorPickerColor: Color = .blue
    @State private var menuBarBattery = true
    @State private var enableAutoAdjust = false
    

    var body: some View {
        // create the tabs that are displayed
        // at the top of the settings page
        TabView {
            GeneralTab.tabItem {
                Image(systemName: "gearshape")
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

