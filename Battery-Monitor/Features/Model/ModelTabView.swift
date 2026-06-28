//
//  ModelTab.swift
//  Battery-Monitor
//
//  Created by Matt on 6/17/26.
//

import SwiftUI

struct ModelTabView: View {
    @EnvironmentObject var model: ModelService
    @AppStorage("selectedColor") private var selectedColorData: Data = Data()
    @State private var selectedAccentColor: Color = .accentColor

    var body: some View {
        VStack {
            List { header() }
                .unscrollableListStyle()
                .frame(minWidth: 300, maxWidth: 500)
                .frame(height: 70)
            
            List {
                if let _ = model.result {
                    Text(model.modelOutput)
                        .standard()
                        .textSelection(.enabled)
                }
                else { LoadingScreen() }
            }
            .scrollableListStyle()
            .logsSpacing()

        }
        .windowPanelStyle("Model Output")
    }
    
    private func header() -> some View {
        return HStack {
            Text("Model Logs")
                .padding(.vertical, 10)
                .font(.system(size: 18, weight: .bold))
            
            Image(systemName: "list.bullet.clipboard")
                .imageScale(.large)
                .foregroundStyle(Color.primary, Color.dataToColor(from: selectedColorData) ?? selectedAccentColor)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private extension View {
    func logsSpacing() -> some View {
        self
        .frame(minWidth: 500, maxWidth: 500, alignment: .top)
        .background(.bar)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
