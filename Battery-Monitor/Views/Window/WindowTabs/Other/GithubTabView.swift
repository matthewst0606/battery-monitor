//
//  GithubTabView.swift
//  Battery-Monitor
//
//  Created by Matt on 6/23/26.
//

import SwiftUI

struct GithubTabView: View {
        
    var body: some View {
        VStack(spacing: 5) {
            Section {
                ScrollView {
                    HStack {


                    }
                }
                .frame(minWidth: 500)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.bar)
                )

                ScrollView {
                    HStack {

                    }
                }
                .frame(minWidth: 500)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.bar)
                )

                
            }
            .focusSection()
        }.appTabStyle()
    }
}
