//
//  BatteryInfo.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//
import Foundation
import SwiftUI

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

// -------------------------
// ===== Menu Toggling =====
// -------------------------
struct BatteryMenuView: View {
    var body: some View {
        AppStorageToggle("Battery Level", key: BatteryMenuKey.level)
        AppStorageToggle("Max Capacity", key: BatteryMenuKey.capacity)
        AppStorageToggle("Time Remaining", key: BatteryMenuKey.timeRemaining)
        AppStorageToggle("Power Source", key: BatteryMenuKey.powerSource)
        AppStorageToggle("Battery Temperature", key: BatteryMenuKey.temperature)
        AppStorageToggle("Low Power Mode", key: BatteryMenuKey.lowPowerMode)
        AppStorageToggle("Charging Status", key: BatteryMenuKey.chargingStatus)
    }
}

enum BatteryMenuKey {
    static let level = "show_battery_level"
    static let capacity = "show_battery_capacity"
    static let timeRemaining = "show_time_remaining"
    static let powerSource = "show_power_source"
    static let temperature = "show_battery_temperature"
    static let lowPowerMode = "show_low_power_mode"
    static let chargingStatus = "show_charging_status"
}
