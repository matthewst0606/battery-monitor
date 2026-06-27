//
//  CustomizeTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/17/26.
//

import SwiftUI
    // creates the elements of the customize tab in settings

enum ShowInMenuBar: String, CaseIterable, Identifiable {
    case timeRemaining, batteryPercent, cycleCount
    var id: Self {self}
}

struct CustomizeTabView: View {
    @EnvironmentObject var cpu: CPUService
    
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @AppStorage("inMenuBar") var inMenuBar: ShowInMenuBar = .timeRemaining
    @AppStorage("menuBarBattery") private var menuBarBattery = true
    @AppStorage("selectedFormat") var selectedFormat: menubarFormat = .regular

    @State private var colorPickerColor: Color = .blue
    
    @State private var selectedStat = ""

    


    
    
    private func createColorPicker(_ title: String, selection: Binding<Color>) -> some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                ColorPicker("", selection: selection)
            }
        }
    }
    
    var body: some View {
        VStack {
            List {
                Toggle("Show in Menubar", isOn: $menuBarBattery)
                    .padding()
                    .toggleStyle(.switch)
                
                if (menuBarBattery) {
                    Picker("Menubar Format", selection: $selectedFormat) {
                        Text("Default").tag(menubarFormat.regular)
                        Text("Compact").tag(menubarFormat.compact)
                    }.padding()
                    
                    
                    if (selectedFormat == .regular) {
                        Picker("Display", selection: $inMenuBar) {
                            Text("Time Remaining").tag(ShowInMenuBar.timeRemaining)
                            Text("Battery Percent").tag(ShowInMenuBar.batteryPercent)
                            Text("Cycle Count").tag(ShowInMenuBar.cycleCount)
                        }.padding()
                    }
                }

                HStack {
                    createColorPicker(
                        "Accent Color",
                        selection: $colorPickerColor
                        
                    )
                    
  
                    settingsButton("Apply", tag: "apply") {
                        if let data = colorPickerColor.colorToData() {
                            selectedColorData = data
                        }
                    }
                }.padding()
            }
            .unscrollableListStyle()
             
        }
        .appTabStyle()
    }
}



