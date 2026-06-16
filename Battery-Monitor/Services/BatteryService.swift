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
import MachO


struct BatteryInfo {
    var batteryLevel: Int
    var timeRemaining: Double
    var timeToFullBattery: Double
    var isCharging: Bool
    var batteryHealth: Int
}


class BatteryMonitor: ObservableObject {
    @Published var info: BatteryInfo?
    private var updateTimer: AnyCancellable?
    
    
    // returns a string that displays how long it will take until
    // battery is dead or fully charged
    var timeRemainingText: String {
        let charging = info?.isCharging ?? false
        let timeToFull = info?.timeToFullBattery ?? 0
        
        if charging { return timeToFull == -1.0 ? "calculating" : "Time to Full: \(timeToFull)" }
        else { return calculateTimeRemaining() == "0:0-1" ? "calculating" : "\(calculateTimeRemaining())" }
    }

    
    init() {
        info = getBatteryInfo()
        updateTimer = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else {return}
                
                if let newInfo = self.getBatteryInfo() {
                    self.info = newInfo
                    self.logBatteryInfo()
                }
                
            }
    }
    
    
    // update battery level, charging status, time to full charge,
    // time to battery depletion, and battery health
    func getBatteryInfo() -> BatteryInfo? {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
    
        
        var batteryLevel: Int = 0
        var timeRemaining: Double = 0.0
        var timeToFullBattery: Double = 0.0
        var isCharging: Bool = false
        var batteryHealth: Int = 0
        
        for source in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, source)
                .takeUnretainedValue() as! [String: Any]
   
            // battery level
            if let level = info[kIOPSCurrentCapacityKey] as? Int
                { batteryLevel = level }
            
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
        
        
        
        return BatteryInfo (
            batteryLevel: batteryLevel,
            timeRemaining: timeRemaining,
            timeToFullBattery: timeToFullBattery,
            isCharging: isCharging,
            batteryHealth: batteryHealth,
        )
    }
    
    
    
    private func logBatteryInfo() {
        guard let info = info else { return }
        
        let url = URL(fileURLWithPath: "/Users/matt/Battery-Monitor/Battery-Monitor/Services/Data/battery.csv")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let timestamp = formatter.string(from: Date())
        let batteryLevel = String(info.batteryLevel)
        let timeRemaining = String(format: "%.4f",info.timeRemaining)
        let isCharging = String(info.isCharging ? 1 : 0)
        let batteryHealth = String(info.batteryHealth)
        
        let row = "\(timestamp),\(batteryLevel),\(timeRemaining),\(isCharging),\(batteryHealth)\n"
        if !FileManager.default.fileExists(atPath: url.path) {
            try? row.write(to: url, atomically: true, encoding: .utf8)
        }
        
        if let handle = try? FileHandle(forWritingTo: url) {
            _ = try? handle.seekToEnd()
            handle.write(row.data(using: .utf8)!)
            try? handle.close()
        }
    }
    
    
    
    
    // formatting:
    // ---------------------------------------
    // gets the correct percent icon according
    // to the current battery level
    var batteryIcon: String {
        let level = info?.batteryLevel ?? 0
        
        switch level {
            case 0..<25:   return "battery.0percent"
            case 25..<50:  return "battery.25percent"
            case 50..<75:  return "battery.50percent"
            case 75..<100: return "battery.75percent"
            default:       return "battery.100percent"
        }
    }

    // format: N hours:N minutes
    func calculateTimeRemaining() -> String {
        let remaining = info?.timeRemaining ?? 0
        
        let hours = Int(remaining/60)
        let minutes = Int(remaining.truncatingRemainder(dividingBy: 60))

        let remain = "\(hours):\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
        return remain;
    }
    
    // format: N hours N minutes
    func calculateTimeRemainingFull() -> String {
        let remaining = info?.timeRemaining ?? 0

        let hours = Int(remaining/60)
        let minutes = Int(remaining.truncatingRemainder(dividingBy: 60))

        let remain = "\(hours) hours \(minutes < 10 ? "0\(minutes) minutes" : "\(minutes) minutes")"
        return remain;
    }
    
    // format: N hours (used in menu bar)
    func calculateTimeRemainingCompact() -> String {
        let remaining = info?.timeRemaining ?? 0

        
        let hours = Int(remaining/60)
        let remain = "\(hours) hours"
        return remain;
    }
    
    // format: N hours N minutes
    func calculateTimeToFullBattery() -> String {
        let timeToFull = info?.timeToFullBattery ?? 0

        
        let hours = Int(timeToFull/60)
        let minutes = Int(timeToFull.truncatingRemainder(dividingBy: 60))

        let remain = "\(hours):\(minutes < 10 ? "0\(minutes)" : "\(minutes)")"
        return remain;
    }
    
    
    

}
