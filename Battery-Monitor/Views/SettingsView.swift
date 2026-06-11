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


struct SettingsView: View {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @AppStorage("selectedMode") var selecteMode: Mode = .system
    @AppStorage("selectedFormat") var selectedFormat: menubarFormat = .regular
    
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
            HStack {
                ColorPicker("", selection: selection).labelsHidden()
            }
        }
    }


    
    // creates the elements of the general tab in settings
    private var GeneralTabView: some View {
        VStack {
            List {
                Picker("Appearance", selection: $selecteMode) {
                    Text("System").tag(Mode.system)
                    Text("Dark").tag(Mode.dark)
                    Text("Light").tag(Mode.light)
                }.padding()

                Picker("Menubar Format", selection: $selectedFormat) {
                    Text("Default").tag(menubarFormat.regular)
                    Text("Compact").tag(menubarFormat.compact)
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
    
    // creates the elements of the customize tab in settings
    private var ModelTabView: some View {
        VStack {
            GroupBox {
                ScrollView {
                    Text(pythonOutput)
                        .widgetText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            }.padding()
        }
    }


    var body: some View {
        // create the tabs that are displayed
        // at the top of the settings page
        TabView {
            ModelTabView.tabItem { Image(systemName: "power.circle.fill") }.tag(0)
            GeneralTabView.tabItem { Image(systemName: "gearshape") }.tag(1)
            CustomizeTabView.tabItem { Image(systemName: "square.and.pencil.circle.fill") }.tag(2)
        }
        .onAppear() {
            if let color = Color.dataToColor(from: selectedColorData)
                { colorPickerColor = color }

            pythonOutput = "Loading..."
            DispatchQueue.global(qos: .background).async {
                let result = modelRunner.getPy()
                DispatchQueue.main.async { pythonOutput = result }
            }
        }
    }
}

