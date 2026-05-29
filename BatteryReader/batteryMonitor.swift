//
//  batteryMonitor.swift
//  app
//
//  Created by Matt on 5/29/26.
//

import Foundation
import Combine
import IOKit.ps

class BatteryMonitor: ObservableObject {
    @Published var batteryLevel: Float = 0.0
    @Published var timeRemaining: Double = 0.0
    @Published var isCharging: Bool = false
  


  
  
    init()
    {
        update()
        Timer.scheduledTimer(withTimeInterval: 25, repeats: true) { _ in
            self.update()
        }
    }
  
    var batteryIcon: String {
        if isCharging { return "battery.100.bolt" }
      
        switch batteryLevel {
          case 0..<25:  return "battery.0"
          case 25..<50: return "battery.25"
          case 50..<75: return "battery.50"
          case 75..<100: return "battery.75"
          default:      return "battery.100"
        }
    }

    func update(){
        let snapshot = IOPSCopyPowerSourcesInfo()
          .takeRetainedValue()
      
        let sources = IOPSCopyPowerSourcesList(snapshot)
          .takeRetainedValue() as Array
      
        for source in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, source)
              .takeUnretainedValue() as! [String: Any]
          
            if let level = info[kIOPSCurrentCapacityKey] as? Int {
                batteryLevel = Float(level)
            }
            if let charging = info[kIOPSIsChargingKey] as? Bool {
                isCharging = charging
            }
            if let remain = info[kIOPSTimeToEmptyKey] as? Double {
                timeRemaining = remain
            }
        }
    }
  
  func calculateTimeRemaining() -> String {
    let hours = Int(timeRemaining/60)
    let minutes = Int(timeRemaining
      .truncatingRemainder(dividingBy: 60))

    let remain = "\(hours):\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
    return remain;
  }
  

}
