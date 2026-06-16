import SwiftUI
import AppKit

enum Mode: String, CaseIterable, Identifiable {
    case system, dark, light
    var id: Self { self }
}

enum menubarFormat: String, CaseIterable, Identifiable {
    case regular, compact
    var id: Self {self}
}

enum updateInterval: String, CaseIterable, Identifiable {
    case one, two, three, five, ten
    var id: Self {self}
}

enum powermetricsInterval: String, CaseIterable, Identifiable {
    case fifteen, thirty, sixty
    var id: Self {self}
}


struct SettingsView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @StateObject private var modelRunner = PythonModelRunner()
    
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    
    @AppStorage("selectedMode") var selectedMode: Mode = .system
    @AppStorage("selectedFormat") var selectedFormat: menubarFormat = .regular
    @AppStorage("selectedUpdateInterval") var selectedUpdateInterval: updateInterval = .two
    @AppStorage("selectedPowermetricsInterval") var selectedPowermetricsInterval: powermetricsInterval = .thirty
    
    @State private var colorPickerColor: Color = .blue
    @State private var menuBarBattery = true
    @State private var enableAutoAdjust = false
    @State private var pythonOutput = ""


    
    
    
    
    private func createToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        GridRow {
            Text(title)
            Toggle("", isOn: isOn).getGlassEffect()
        }
    }
    private func createColorPicker(_ title: String, selection: Binding<Color>) -> some View {
        GridRow {
            Text(title)
            HStack { ColorPicker("", selection: selection).labelsHidden() }
        }
    }


    
    // creates the elements of the general tab in settings
    private var GeneralTabView: some View {
        VStack(alignment: .center) {
            List {
                Picker("Appearance", selection: $selectedMode) {
                    Text("System").tag(Mode.system)
                    Text("Dark").tag(Mode.dark)
                    Text("Light").tag(Mode.light)
                }.padding()

                Picker("Menubar Format", selection: $selectedFormat) {
                    Text("Default").tag(menubarFormat.regular)
                    Text("Compact").tag(menubarFormat.compact)
                }.padding()
                
                Picker("Update Interval", selection: $selectedUpdateInterval) {
                    Text("1s").tag(updateInterval.one)
                    Text("2s (default)").tag(updateInterval.two)
                    Text("3s").tag(updateInterval.three)
                    Text("5s").tag(updateInterval.five)
                    Text("10s").tag(updateInterval.ten)

                }.padding()
                
                Picker("Powermetrics Interval", selection: $selectedPowermetricsInterval) {
                    Text("15s").tag(powermetricsInterval.fifteen)
                    Text("30s (default)").tag(powermetricsInterval.thirty)
                    Text("60s").tag(powermetricsInterval.sixty)
                }.padding()

                Toggle("Show in Menubar", isOn: $menuBarBattery)
                    .padding().toggleStyle(.switch)
                
                Toggle("Enable Auto Adjust", isOn: $enableAutoAdjust)
                    .padding().toggleStyle(.switch)
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .background(.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()

            // quit button
            Button("Quit App") { NSApp.terminate(nil) }
                .buttonGlassEffect()
                .padding()
        }
    }
    
    // creates the elements of the customize tab in settings
    private var CustomizeTabView: some View {
        VStack {
            GroupBox {
                Grid(alignment: .trailing, horizontalSpacing: 9, verticalSpacing: 15)
                    { createColorPicker("Accent Color:", selection: $colorPickerColor) }
            }
            HStack {
                Button("Apply") {
                    if let data = colorPickerColor.colorToData()
                        {selectedColorData = data }
                }.buttonGlassEffect()
                
                Button("Reset") {
                    if let data = colorPickerColor.colorToData()
                        { selectedColorData = data }
                }.buttonGlassEffect()
            }.padding()
        }
    }

    var body: some View {
        // create the tabs that are displayed
        // at the top of the settings page
        TabView {
            GeneralTabView.tabItem { Image(systemName: "gearshape") }.tag(1)
            CustomizeTabView.tabItem { Image(systemName: "square.and.pencil.circle.fill") }.tag(2)
        }
        .onAppear() {
            if let color = Color.dataToColor(from: selectedColorData)
                { colorPickerColor = color }
        }
    }
}

