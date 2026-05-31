import SwiftUI
import AppKit



extension Color {
    func colorToData() -> Data? {
        let nsColor = NSColor(self)
        return try? NSKeyedArchiver
            .archivedData(
                withRootObject: nsColor,
                requiringSecureCoding: false
            )
    }
    
    static func dataToColor(from data: Data) -> Color? {
        if let nsData = try? NSKeyedUnarchiver
            .unarchivedObject(
                ofClass: NSColor.self,
                from: data
            ) {
            return Color(nsColor: nsData)
        }
        return nil
    }
}


struct SettingsView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    
    @State private var colorPickerColor: Color = .blue
    @State private var darkMode = true
    @State private var menuBarBattery = false


  
    var body: some View {
        TabView {
        
            Tab("general", systemImage: "gear") {
                GroupBox {
                    Text("settings")
                        .padding(.horizontal, 25)
                        .padding(.vertical, 5)
                        .font(.system(size: 16, weight: .bold))
                    
                    Grid(alignment: .trailing, horizontalSpacing: 9, verticalSpacing: 15) {
                        GridRow {
                            Text("Toggle dark mode")
                            Toggle("", isOn: $darkMode).labelsHidden()
                        }
                        GridRow {
                            Text("Show percentage")
                            Toggle("", isOn: $menuBarBattery).labelsHidden()
                        }
                    }
                    .padding()
                    .toggleStyle(.switch)
                }
                
                HStack {
                    Button("Quit App") { NSApp.terminate(nil) }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
            }

            
            
            Tab("customize", systemImage: "pencil") {
            
                GroupBox {
                    Text("customize")
                        .padding(EdgeInsets(top: 5, leading: 25, bottom:  5, trailing: 25))
                        .font(.system(size: 16, weight: .bold))
                    
                    Grid(
                        alignment: .trailing,
                        horizontalSpacing: 9,
                        verticalSpacing: 15
                    ) {
                        GridRow {
                            Text("Accent Color")
                            HStack {
                                ColorPicker("", selection: $colorPickerColor)
                                    .labelsHidden()
                            }
                        }
                    }
                    .padding()
                    .toggleStyle(.switch)
                    
                    Button("Apply") {
                        if let data = colorPickerColor.colorToData() {
                            selectedColorData = data
                        }
                    }
                    .padding()
                }
            }
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
