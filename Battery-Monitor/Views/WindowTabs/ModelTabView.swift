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
        .padding(20)
        .frame(minWidth: 500, maxWidth: 500, maxHeight: 500, alignment: .top)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .frame(minWidth: 600, maxHeight: .infinity, alignment: .top)
        .navigationTitle(Text("Model Output"))
        
        .onAppear() {
            modelRunner.updatePy()
        }
    }
}
