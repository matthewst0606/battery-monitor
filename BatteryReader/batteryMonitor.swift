//
//  batteryMonitor.swift
//  app
//
//  Created by Matt on 5/29/26.
//

import Foundation
import Combine
import IOKit.ps
import SwiftUI

class BatteryMonitor: ObservableObject {
    @Published var batteryLevel: Float = 0.0
    @Published var timeRemaining: Double = 0.0
    @Published var timeToFullBattery: Double = 0.0
    @Published var isCharging: Bool = false
    @Published var batteryHealth: Int = 0


  
    init() {
        update()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true)
            { _ in self.update() }
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
   
            // battery level
            if let level = info[kIOPSCurrentCapacityKey] as? Int
                { batteryLevel = Float(level) }
            
            // is device charging
            if let charging = info[kIOPSIsChargingKey] as? Bool
                { isCharging = charging }
            
            if let timeToCharge = info[kIOPSTimeToFullChargeKey] as? Double
                { timeToFullBattery = timeToCharge }
            
            // estimated time remaining
            if let remaining = info[kIOPSTimeToEmptyKey] as? Double
                { timeRemaining = remaining }
            
            if let health = info[kIOPSMaxCapacityKey] as? Int
                { batteryHealth = health }
        }
    }
    
// ------------------------------------------------------------------------------
    // format: N hours:N minutes
    func calculateTimeRemaining() -> String {
        let hours = Int(timeRemaining/60)
        let minutes = Int(timeRemaining
            .truncatingRemainder(dividingBy: 60)
        )

        let remain = "\(hours):\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
        return remain;
    }
    
    // format: N hours N minutes
    func calculateTimeRemainingFull() -> String {
        let hours = Int(timeRemaining/60)
        let minutes = Int(timeRemaining.truncatingRemainder(dividingBy: 60))

        let remain = "\(hours) hours \(minutes < 10 ? "0\(minutes) minutes" : "\(minutes) minutes")"
        return remain;
    }
    
    // format: N hours
    func calculateTimeRemainingCompact() -> String {
        let hours = Int(timeRemaining/60)
        let remain = "\(hours) hours"
        return remain;
    }
// ------------------------------------------------------------------------------
    func calculateTimeToFullBattery() -> String {
        let hours = Int(timeToFullBattery/60)
        let minutes = Int(timeToFullBattery.truncatingRemainder(dividingBy: 60))

        let remain = "\(hours):\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
        return remain;
    }
}
