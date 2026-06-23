//
//  OtherTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/23/26.
//
import SwiftUI

struct OtherTabView: View {
    @EnvironmentObject var model: ModelService
    
    private var ChangelogTab: some View { ChangeLogTabView() }
    private var GithubTab: some View { GithubTabView() }
    @State private var selectedOther = "changelog"
    
    var body: some View {
        VStack {
            HStack {
                createTab(title: "Change Log", tag: "changelog", selectedStat: $selectedOther)
                createTab(title: "Github", tag: "github", selectedStat: $selectedOther)
            }
            .frame(minWidth: 300, maxWidth: 500)
            
            
            switch selectedOther {
            case "changelog": ChangelogTab
            case "github": GithubTab
            default: ChangelogTab
            }
        }
        .windowTabStyle(title: "Other")
    }
}
