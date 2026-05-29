//
//  ContentView.swift
//  app
//
//  Created by Matt on 5/28/26.
//

import SwiftUI
import IOKit.ps


struct ContentView: View {
  @StateObject private var monitor = BatteryMonitor()

  let textSize: CGFloat = 14

  
  
  var body: some View {
    VStack(alignment: .center, spacing: 15) {
      ZStack {
        Image(systemName: "\(monitor.batteryIcon)")
          .font(.system(size: 30, weight: .light))
          .imageScale(.medium)
          .symbolRenderingMode(.palette)
          .foregroundStyle(Color.accentColor, Color.primary)
        
        Text("\(Int(monitor.batteryLevel))%")
          .offset(x: -1.5)
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(.white)
          .minimumScaleFactor(0.5)
      }
      
      Text("Time Remaining: \(monitor.calculateTimeRemaining())")
        .font(.system(size: 12, weight: .bold,))
        .foregroundStyle(.white)
      
    }
    .padding(17)
    .onAppear() { monitor.update() }
  }
  
}


#Preview {
  ContentView()
}
