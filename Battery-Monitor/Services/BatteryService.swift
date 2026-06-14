//
//  batteryMonitor.swift
//  app
//
//  Created by Matt on 5/29/26.
//

import Foundation
import Combine
import IOKit.ps
import IOKit.graphics
import SwiftUI
import AppKit


class BatteryMonitor: ObservableObject {
    @Published var batteryLevel: Float = 0.0
    @Published var timeRemaining: Double = 0.0
    @Published var timeToFullBattery: Double = 0.0
    @Published var isCharging: Bool = false
    @Published var batteryHealth: Int = 0
    private var updateTimer: AnyCancellable?
    
    

    // the info is updated every 20 seconds
    init() {
        update()
        print("CPU timer fired")
        updateTimer = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.update() }
    }
    
    // update battery level, charging status, time to full charge,
    // time to battery depletion, and battery health
    func update(){
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
    
      
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
    
    
    
    
    
    
    
    
    // formatting:
    // ---------------------------------------
    // gets the correct percent icon according
    // to the current battery level
    var batteryIcon: String {
        switch batteryLevel {
            case 0..<25:   return "battery.0percent"
            case 25..<50:  return "battery.25percent"
            case 50..<75:  return "battery.50percent"
            case 75..<100: return "battery.75percent"
            default:       return "battery.100percent"
        }
    }

    // format: N hours:N minutes
    func calculateTimeRemaining() -> String {
        let hours = Int(timeRemaining/60)
        let minutes = Int(timeRemaining.truncatingRemainder(dividingBy: 60))

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
    
    // format: N hours (used in menu bar)
    func calculateTimeRemainingCompact() -> String {
        let hours = Int(timeRemaining/60)
        let remain = "\(hours) hours"
        return remain;
    }
    
    // format: N hours N minutes
    func calculateTimeToFullBattery() -> String {
        let hours = Int(timeToFullBattery/60)
        let minutes = Int(timeToFullBattery.truncatingRemainder(dividingBy: 60))

        let remain = "\(hours):\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
        return remain;
    }
}
