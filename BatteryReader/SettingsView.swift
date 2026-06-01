import SwiftUI
import AppKit


struct SettingsView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    
    @State private var colorPickerColor: Color = .blue
    @State private var darkMode = true
    @State private var menuBarBattery = true
    
    
    private func createGridRowToggle(_ title: String, isOn: Binding<Bool>) -> some
    View {
        GridRow {
            Text(title)
            Toggle("", isOn: isOn)
                .gridRowGlassEffect()
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
            
            HStack {
                Button("Quit App") { NSApp.terminate(nil) }
                    .buttonGlassEffect()
            }
            .padding()
        }
    }
    
    
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


    var body: some View {
        TabView {
            Tab("general", systemImage: "gear") { GeneralTabView }
            Tab("customize", systemImage: "pencil") { CustomizeTabView }
        }
        .frame(width: 300, height: 300)
        .onAppear() {
            if let color = Color.dataToColor(from: selectedColorData) {
                colorPickerColor = color
            }
        }
    }
}

#Preview { SettingsView() }
