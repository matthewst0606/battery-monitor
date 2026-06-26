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
import Charts

class BatteryService: ObservableObject {
    @Published var info: BatteryInfo?
    private let timerService = TimerService()
    
    
    // returns a string that displays how long it will take until
    // battery is dead or fully charged
    var timeRemainingText: String {
        let charging = info?.isCharging ?? false
        let timeToFull = info?.timeToFullBattery ?? 0
        
        if charging { 
            return timeToFull == -1.0 ? "calculating..." : "\(calculateTimeToFullBattery())" 
        }
        else { 
            return calculateTimeRemaining() == "0:0-1" ? "calculating..." : "\(calculateTimeRemaining())" 
        }
    }

    init() {
        self.info = getBatteryInfo()
        timerService.createTimer {
            if let newInfo = self.getBatteryInfo() {
                self.logBatteryInfo(newInfo)
                self.info = newInfo
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
        
        
        let uptime = ProcessInfo.processInfo.systemUptime
        
        var powerMode: Int = 0
        switch ProcessInfo.processInfo.isLowPowerModeEnabled {
        case true: powerMode = 1
        default: powerMode = 0
        }
        
        
        let cycleCount = getSmartBatteryInfo(kIOPMPSCycleCountKey)
        let temperature = Double(getSmartBatteryInfo(kIOPMPSBatteryTemperatureKey)) / 100.0
        
        // gets current battery level, the charging status,
        // time to full charge, time to battery depletion,
        // max capacity, power source, and battery health
        for source in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, source)
                .takeUnretainedValue() as! [String: Any]

            return BatteryInfo (
                batteryLevel:  info[kIOPSCurrentCapacityKey] as? Int ?? 0,
                timeRemaining: info[kIOPSTimeToEmptyKey] as? Double ?? 0,
                timeToFullBattery: info[kIOPSTimeToFullChargeKey] as? Double ?? 0,
                isCharging: info[kIOPSIsChargingKey] as? Bool ?? false,
                maxCapacity: info[kIOPSMaxCapacityKey] as? Int ?? 0,
                batteryHealth: info[kIOPSBatteryHealthKey] as? String ?? "",
                powerMode: powerMode,
                uptime: uptime,
                powerSourceState: info[kIOPSPowerSourceStateKey] as? String ?? "" ,
                cycleCount: cycleCount,
                temperature: temperature
            )
        }
        return nil
    }
    
    
    // appends the new battery info to battery.csv
    private func logBatteryInfo(_ info: BatteryInfo) {
        let values = [
            logCSVTimestamp(),
            String(info.batteryLevel),
            String(info.maxCapacity),
            String(info.batteryHealth),
            String(format: "%.0f",info.timeRemaining),
            String(info.powerMode),
            String(info.isCharging ? 1 : 0),
            String(info.cycleCount),
            String(info.temperature)
            
        ]
        logToCSV("battery.csv", values)
    }
    

    


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

    private func formatMinutes(_ minutes: Double) -> String {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))

        return "\(hours):\(mins < 10 ? "0\(mins)" : "\(mins)")"
    }

    // format: N hours:N minutes
    func calculateTimeRemaining() -> String {
        formatMinutes(info?.timeRemaining ?? 0)
    }
    
    // format: N hours N minutes
    func calculateTimeToFullBattery() -> String {
        formatMinutes(info?.timeToFullBattery ?? 0)
    }


    // format: N hours (used in menu bar for minimizing space used)
    func calculateTimeRemainingCompact() -> String {
        let remaining = info?.timeRemaining ?? 0
        let hours = Int(remaining/60)
    
        return  "\(hours) hours"
    }
}

