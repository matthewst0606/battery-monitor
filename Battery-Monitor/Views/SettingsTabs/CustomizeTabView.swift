//
//  CustomizeTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/17/26.
//

import SwiftUI
    // creates the elements of the customize tab in settings
struct CustomizeTabView: View {
    @EnvironmentObject var monitor: BatteryMonitor
    @EnvironmentObject var cpu: CPUService
    
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var colorPickerColor: Color = .blue
    @State private var menuBarBattery = true
    @State private var enableAutoAdjust = false
    
    
    private func createColorPicker(_ title: String, selection: Binding<Color>) -> some View {
        GridRow {
            Text(title)
            HStack {
                ColorPicker("", selection: selection)
                    .labelsHidden()
            }
        }
    }
    
    var body: some View {
        VStack {
            GroupBox {
                Grid(
                    alignment: .trailing,
                    horizontalSpacing: 9,
                    verticalSpacing: 15
                ) {
                    createColorPicker(
                        "Accent Color:",
                        selection: $colorPickerColor
                    )
                }

            }

            HStack {
                
                Button {
                    if let data = colorPickerColor.colorToData() {
                        selectedColorData = data
                    }
                }
                label: {
                    Text("Apply")
                        .padding(.vertical, 2)
                        .padding(.horizontal, 5)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)

                Button {
                    if let data = colorPickerColor.colorToData() {
                        selectedColorData = data
                    }
                }
                label: {
                    Text("Reset")
                        .padding(.vertical, 2)
                        .padding(.horizontal, 5)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 50)
    }
}

