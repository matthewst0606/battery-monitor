import SwiftUI
import AppKit


struct SettingsView: View {
    @StateObject private var monitor = BatteryMonitor()
    @StateObject private var modelRunner = PythonModelRunner()
    
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    
    @State private var colorPickerColor: Color = .blue
    @State private var darkMode = true
    @State private var menuBarBattery = true
    @State private var pythonOutput = ""


    private func createGridRowToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        GridRow {
            Text(title)
            Toggle("", isOn: isOn).gridRowGlassEffect()
        }
    }
    private func createColorPicker(_ title: String, selection: Binding<Color>) -> some View {
        GridRow {
            Text(title)
            HStack {
                ColorPicker("", selection: selection)
                    .labelsHidden()
            }
        }
    }

    // creates the elements of the general tab in settings
    private var GeneralTabView: some View {
        VStack {
            GroupBox {
                Grid(alignment: .trailing, horizontalSpacing: 9, verticalSpacing: 15) {
                    GridRow {
                        Text("Appearance")
                        
                        Picker("", selection: $darkMode) {
                            Text("System").tag(true)
                            Text("Dark")
                            Text("Light")
                        }
                        .labelsHidden()
                    }
                    GridRow {
                        Text("Menubar Format")
                        
                        Picker("", selection: $darkMode) {
                            Text("Default").tag(true)
                            Text("Compact")
                        }
                        .labelsHidden()
                    }
                    createGridRowToggle("Show in Menubar", isOn: $menuBarBattery)
                }
                .gridStyle()
            }
            // quit button
            HStack {
                Button("Quit App") { NSApp.terminate(nil) }
                    .buttonGlassEffect()
            }
            .padding()
        }
    }
    
    // creates the elements of the customize tab in settings
    private var CustomizeTabView: some View {
        VStack {
            GroupBox {
                Grid(alignment: .trailing, horizontalSpacing: 9, verticalSpacing: 15) {
                    createColorPicker("Accent Color:", selection: $colorPickerColor)
                }
                .gridStyle()
            }
            
            HStack {
                Button("Apply") {
                    if let data = colorPickerColor.colorToData() {
                        selectedColorData = data
                    }
                }
                .buttonGlassEffect()
                
                Button("Reset") {
                    if let data = colorPickerColor.colorToData() {
                        selectedColorData = data
                    }
                }
                .buttonGlassEffect()
            }
            .padding()
        }
    }
    
    // creates the elements of the customize tab in settings
    private var ModelTabView: some View {
        VStack {
            GroupBox {
                ScrollView {
                    Text(pythonOutput)
                        .font(.system(size: 10, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)

                }
                .frame(width: 300, height: 200)
            }
            .padding()
        }
    }


    var body: some View {
        // create the tabs that are displayed
        // at the top of the settings page
        TabView {
            Tab("Model Output", systemImage: "gear") { ModelTabView }
            Tab("General", systemImage: "gear") { GeneralTabView }
            Tab("Customize", systemImage: "pencil") { CustomizeTabView }
        }
        .frame(width: 400, height: 300)
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

#Preview { SettingsView() }
