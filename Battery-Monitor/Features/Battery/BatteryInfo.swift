//
//  BatteryInfo.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//
import Foundation

struct BatteryInfo {
    var batteryLevel: Int
    var timeRemaining: Double
    var timeToFullBattery: Double
    var isCharging: Bool
    var maxCapacity: Int
    var batteryHealth: String
    var powerMode: Int
    var uptime: TimeInterval
    var powerSourceState: String
    var cycleCount: Int
    var temperature: Double
    
}
