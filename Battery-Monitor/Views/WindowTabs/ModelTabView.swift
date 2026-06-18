//
//  ModelTab.swift
//  Battery-Monitor
//
//  Created by Matt on 6/17/26.
//

import SwiftUI

struct ModelTabView: View {
    @EnvironmentObject var modelRunner: PythonModelRunner
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Model Output")
                    .widgetText()
                    .padding(.vertical, 15)
            }
            .frame(minWidth: 450, maxWidth: 450, alignment: .top)
            .background(.bar)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            ScrollView {
                Text(modelRunner.modelOutput)
                    .widgetText()
                    .textSelection(.enabled)
            }
        }
        .windowTabStyle(title: "Model Output")
        .navigationTitle(Text("Model Output"))
    }
}
