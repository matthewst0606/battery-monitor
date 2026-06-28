//
//  PythonResultExtension.swift
//  Battery-Monitor
//
//  Created by Matt on 6/27/26.
//

import Foundation

extension PythonResult {
    var feature: [String: Double] { features }
    func double(_ key: String) -> Double { features[key] ?? 0 }
    func int(_ key: String) -> Int { Int(double(key)) }
}


extension PythonResult {
    var timeRemaining: Double { Double(prediction) }
    var batteryPercent: Int { int("Battery_Percent") }
    var maximumCapacity: Int { int("Maximum_Capacity") }
    var cycleCount: Int { int("Cycle_Count") }
    var condition: String {
        let cond = int("Battery_Condition")
        switch cond {
        case 0: return "Normal"
        case 1: return "Service Recommended"
        default: return "Battery Condition Unknown"
        }
    }
}

extension PythonResult {
    var totalMemory: Double { double("Total_Memory") }
    var usedMemory: Double { double("Used_Memory") }
}

extension PythonResult {
    var numOfProcesses: Int { int("Process_Count") }
    var processPower: Double{ double("Process_Power") }
    var processState: Int{ int("Process_State") }
}
extension PythonResult {
    var cpuUsage: Double { double("CPU_Usage")}
    var cpuFrequency: Double{ double("old_CPU_Frequency")}
    var cpuResidency: Double{ double("old_CPU_Residency")}
    var cpuIdle:Double { double("CPU_Idle")}
    var cpuPower:Double{ double("old_CPU_Power") / 1000 }
}

extension PythonResult {
    var gpuFrequency: Double{ double("Avg_GPU_Frequency") }
    var gpuResidency: Double{ double("Avg_GPU_Residency") }
    var gpuIdle:Double { double("Avg_GPU_idle") }
    var gpuPower:Double{ double("GPU_Power") / 1000 }
    var gpuUsage: Double { Double(100 - self.gpuIdle) }
}

extension PythonResult {
    var predictionSummary: String {
        summary ?? "Estimated \(prediction) minutes remaining."
    }

    var drainRateText: String {
        guard let value = details?.drainPercentPerHour,value > 0 else { return "Unknown" }
        return String(format: "%.1f%% / hr", value)
    }
    
    var avgDrainRateText: String {
        guard let value = details?.avgDrainPerHour, value > 0 else { return "Unknown" }
        return String(format: "%.1f%% / hr", value)
    }
    
    var drainRateDeltaText: String {
        guard let current = details?.drainPercentPerHour, current > 0,
              let average = details?.avgDrainPerHour, average > 0
        else { return "Unknown" }
        
        let delta = Double(average - current)
        
        if delta > 0.0 { return String(format: "saving ~%.1f%% more than average.", abs(delta)) }
        else { return String(format: "about ~%.1f%% faster than average.", abs(delta)) }
    }

    var fullRuntimeText: String {
        guard let minutes = details?.fullRuntimeMinutes, minutes > 0 else { return "Unknown" }
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours > 0 { return "\(hours)h \(remainder)m" }
        return "\(remainder)m"
    }
}
