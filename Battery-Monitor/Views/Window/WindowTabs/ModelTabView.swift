//
//  ModelTab.swift
//  Battery-Monitor
//
//  Created by Matt on 6/17/26.
//

import SwiftUI

struct ModelTabView: View {
    @EnvironmentObject var model: ModelService

    
    var body: some View {
        VStack {
            HStack {
                Text("Model Logs")
                    .widgetText()
                    .padding(.vertical, 15)
            }
            .frame(minWidth: 500, maxWidth: 500, alignment: .top)
            .background(.bar)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            ScrollView {
                Text(model.modelOutput)
                    .widgetText()
                    .textSelection(.enabled)
            }
            .frame(minWidth: 500, maxWidth: 500, alignment: .top)
            .background(.bar)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .windowTabStyle(title: "Model Output")
        .navigationTitle(Text("Model Output"))
    }
}
