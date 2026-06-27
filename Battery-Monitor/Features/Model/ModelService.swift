//
//  ModelService.swift
//  Battery-Monitor
//
//  Created by Matt on 6/8/26.
//
import Foundation
import Combine
import IOKit.ps
import SwiftUI


class ModelService: ObservableObject {
    @AppStorage("selectedPowermetricsInterval") var selectedPowermetricsInterval: PowermetricsInterval = .thirty
    @Published var modelOutput = ""
    @Published var result: PythonResult?
    
    private var pythonTimer: AnyCancellable?
    var isRunningPython = false

    
    init(powerSourceState: String?) {
        pythonTimer = Timer.publish(
            every: TimeInterval(selectedPowermetricsInterval.rawValue),
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            
            guard let self = self,
                    !self.isRunningPython,
                    powerSourceState != "AC Power"
            else { return }
            
            self.isRunningPython = true
            
            DispatchQueue.global(qos: .background).async {
                _ = self.getPy()
                
                DispatchQueue.main.async {
                    self.isRunningPython = false
                }
            }
        }
    }
    
    
    
    func getPy() -> String {
        let (process, outputPipe, errorPipe) = makePythonProcess()
        
        do {
            try process.run()
        }
        catch { print("Failed to run Python:", error) }

        let output = String(
            data: outputPipe.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""
        let error = String(
            data: errorPipe.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""
        
        
        guard error.isEmpty else {
            print("Battery Model error occured!:", error)
            DispatchQueue.main.async {
                self.modelOutput = error
            }
            return error
        }
        

        DispatchQueue.main.async {
            self.modelOutput = output

            if let data = output.data(using: .utf8),
               let result = try? JSONDecoder().decode(PythonResult.self, from: data) {
                self.result = result
            }
        }
        
        
        print(output)
        return output
    }
    
    
    
        
    private func makePythonProcess() -> (process: Process, outputPipe: Pipe, errorPipe: Pipe) {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        let scriptDir = Bundle.main.resourceURL!

        do {
            for fileName in ["system_info.csv", "cpu.csv", "memory.csv", "battery.csv"] {
                let fileURL = try appDataDirectory(fileName: fileName)
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    throw CocoaError(.fileNoSuchFile)
                }
            }
            let dataDirectory = try appDataDirectory()
            
            var environment = ProcessInfo.processInfo.environment
            environment["BATTERY_MONITOR_DATA_DIR"] = dataDirectory.path
            process.environment = environment
            
        } catch {
            print("Unable to prepare model data directory:", error)
        }
        
        process.arguments = [scriptDir.appendingPathComponent("main.py").path]
        process.currentDirectoryURL = scriptDir
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        return (process, outputPipe, errorPipe)
    }
    

    func updatePy(powerSourceState: String?) {
        guard !isRunningPython,
              powerSourceState != "AC Power"
        else { return }
        isRunningPython = true
        self.modelOutput = "Loading..."
        
        DispatchQueue.global(qos: .background).async {
            _ = self.getPy()
            
            DispatchQueue.main.async {
                self.isRunningPython = false
            }
        }
    }
    
    
    
    func formatBatteryPrediction(_ value: Double) -> String {
        let raw = Int(value.rounded())
        let hours = raw / 60
        let minutes = raw % 60
        
        if hours > 0 { return "\(hours)h \(minutes)m" }
        else { return "\(minutes)m" }
    }
}


struct PythonResult: Codable {
    let features: [String: Double]
    let prediction: Int
    let summary: String?
    let confidence: PredictionConfidence?
    let drivers: [PredictionDriver]?
    let details: PredictionDetails?
    
}

extension PythonResult {
    var feature: [String: Double] { features }

    func double(_ key: String) -> Double {
        features[key] ?? 0
    }

    func int(_ key: String) -> Int {
        Int(double(key))
    }
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




struct PredictionConfidence: Codable {
    let level: String
    let reason: String
    let distanceFromTrainingData: Double
}

struct PredictionDriver: Codable, Identifiable {
    var id: String { key }
    let name: String
    let key: String
    let value: Double
    let average: Double
    let difference: Double
    let zScore: Double
    let direction: String
    let strength: Double

    var shortDescription: String {
        let formattedValue = String(format: "%.1f", value)
        let formattedAverage = String(format: "%.1f", average)
        return "\(formattedValue) vs usual \(formattedAverage)"
    }
}

struct PredictionDetails: Codable {
    let drainPercentPerHour: Double
    let fullRuntimeMinutes: Int
    let avgDrainPerHour: Double

}
