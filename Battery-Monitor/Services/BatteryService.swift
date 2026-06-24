//
//  batteryService.swift
//  app
//
//  Created by Matt on 5/29/26.
//

import Foundation
import Combine
import IOKit.ps
import IOKit.pwr_mgt
import IOKit.graphics
import SwiftUI
import AppKit
import MachO
import CoreGraphics

class BatteryService: ObservableObject {
    @Published var info: BatteryInfo?
    private let serviceHelper = ServiceHelper()
    
    
    // returns a string that displays how long it will take until
    // battery is dead or fully charged
    var timeRemainingText: String {
        let charging = info?.isCharging ?? false
        let timeToFull = info?.timeToFullBattery ?? 0
        
        if charging { return timeToFull == -1.0 ? "calculating" : "Time to Full: \(timeToFull)" }
        else { return calculateTimeRemaining() == "0:0-1" ? "calculating" : "\(calculateTimeRemaining())" }
    }

    init() {
        self.info = getBatteryInfo()
        serviceHelper.createTimer {
            if let newInfo = self.getBatteryInfo() {
                self.info = newInfo
                self.logBatteryInfo()
            }
        }
    }
    
    
    
    
    
    
    private func getSmartBatteryInfo(_ key: String) -> Int {
        let service = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("AppleSmartBattery")
        )

        guard service != 0 else { return -1 }
        defer { IOObjectRelease(service) }

        
        let value = IORegistryEntryCreateCFProperty(
            service,
            key as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? NSNumber
    
        return value?.intValue ?? 0
    }
    
    
    private func getOther(_ key: String) -> String {
        let service = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPowerManagement")
        )

        guard service != 0 else { return "nil" }
        defer { IOObjectRelease(service) }

        
        let value = IORegistryEntryCreateCFProperty(
            service,
            key as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? NSNumber
    
        return value?.stringValue ?? "nil"
    }
    
    
    

    // update battery level, charging status, time to full charge,
    // time to battery depletion, and battery health
    func getBatteryInfo() -> BatteryInfo? {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
        var batteryLevel: Int = 0
        var timeRemaining: Double = 0
        var timeToFullBattery: Double = 0
        var isCharging: Bool = false
        var batteryHealth: Int = 0
        var batteryCondition: String = ""
        var powerMode: Int = 0
        var powerSourceState: String = ""
        
        let uptime = ProcessInfo.processInfo.systemUptime

        switch ProcessInfo.processInfo.isLowPowerModeEnabled {
        case true: powerMode = 1
        default: powerMode = 0
        }
        
        
        let cycleCount = getSmartBatteryInfo(kIOPMPSCycleCountKey)
        let temperature = Double(getSmartBatteryInfo(kIOPMPSBatteryTemperatureKey)) / 100.0
        
        
        for source in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, source)
                .takeUnretainedValue() as! [String: Any]
   
            // battery level
            if let currentLevel = info[kIOPSCurrentCapacityKey] as? Int
                { batteryLevel = currentLevel }
            
            // is device charging
            if let chargingStatus = info[kIOPSIsChargingKey] as? Bool
                { isCharging = chargingStatus }
            
            // estimated time to charge
            if let timeToCharge = info[kIOPSTimeToFullChargeKey] as? Double
                { timeToFullBattery = timeToCharge }
            
            // estimated time remaining
            if let currentTimeRemaining = info[kIOPSTimeToEmptyKey] as? Double
                { timeRemaining = currentTimeRemaining }
            
            // current battery health
            if let currentHealth = info[kIOPSMaxCapacityKey] as? Int
                { batteryHealth = currentHealth }
            
            // current power source state
            if let currentPowerSourceState = info[kIOPSPowerSourceStateKey] as? String
                { powerSourceState = currentPowerSourceState }
            
            
            if let condition = info[kIOPSBatteryHealthKey] as? String
                { batteryCondition = condition }

        }
        
        return BatteryInfo (
            batteryLevel: batteryLevel,
            timeRemaining: timeRemaining,
            timeToFullBattery: timeToFullBattery,
            isCharging: isCharging,
            batteryHealth: batteryHealth,
            batteryCondition: batteryCondition,
            powerMode: powerMode,
            uptime: uptime,
            powerSourceState: powerSourceState,
            cycleCount: cycleCount,
            temperature: temperature
        )
    }
    
    
    // appends the new battery info to battery.csv
    private func logBatteryInfo() {
        guard let info = info else { return }
        let values = [
            logTimestamp(),
            String(info.batteryLevel),
            String(info.batteryHealth),
            String(info.batteryCondition),
            String(format: "%.0f",info.timeRemaining),
            String(info.powerMode),
            String(info.isCharging ? 1 : 0),
            String(info.cycleCount),
            String(info.temperature)
            
        ]
        
        logToCSV("battery.csv", values)
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
    
    
    func formatHMS(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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

struct BatteryInfo {
    var batteryLevel: Int
    var timeRemaining: Double
    var timeToFullBattery: Double
    var isCharging: Bool
    var batteryHealth: Int
    var batteryCondition: String
    var powerMode: Int
    var uptime: TimeInterval
    var powerSourceState: String
    var cycleCount: Int
    var temperature: Double
    
}
