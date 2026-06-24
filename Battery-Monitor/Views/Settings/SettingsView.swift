import SwiftUI
import AppKit

struct SettingsView: View {
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var colorPickerColor: Color = .blue
    @State private var selectedTab = "general"

    
    private var CustomizeTab: some View { CustomizeTabView() }
    private var GeneralTab: some View { GeneralTabView() }


    var body: some View {
        // create the tabs that are displayed at the top of the settings page

                VStack(alignment: .center, spacing: 10) {
                    
                    HStack {
                        createTab(title: "General", tag: "general", selectedStat: $selectedTab)
                        createTab(title: "Model", tag: "model", selectedStat: $selectedTab)

                        createTab(title: "Customize", tag: "customize", selectedStat: $selectedTab)
                    }
                    .frame(minWidth: 300, maxWidth: 500)

                    switch selectedTab {
                    case "general": GeneralTab
                    case "model": GeneralTab

                    case "customize": CustomizeTab
                    default: GeneralTab
                    }
                    
                    HStack {
                        settingsButton("Clear Data") { NSApp.terminate(nil) }
                        settingsButton("Quit App") { NSApp.terminate(nil) }
                    }
                }
                .windowTabStyle(title: "Settings")
            

        

        .onAppear() {
            if let color = Color.dataToColor(from: selectedColorData) {
                colorPickerColor = color
            }
        }
    }
}

