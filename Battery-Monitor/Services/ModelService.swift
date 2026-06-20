//
//  PythonModelRunner.swift
//  Battery-Monitor
//
//  Created by Matt on 6/8/26.
//
import Foundation
import Combine
import IOKit.ps
import SwiftUI


class PythonModelRunner: ObservableObject {
    @AppStorage("selectedPowermetricsInterval") var selectedPowermetricsInterval: PowermetricsInterval = .thirty
    @Published var modelOutput = ""
    @Published var result: PythonResult?
    
    private var pythonTimer: AnyCancellable?
    private var isRunningPython = false
    private let serviceHelper = ServiceHelper()
    
    
    init() {
        pythonTimer = Timer.publish(
            every: TimeInterval(selectedPowermetricsInterval.rawValue),
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            
            guard let self = self, !self.isRunningPython else {
                return
            }
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
        
        do { try process.run() }
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
            return error
        }
        

        if let data = output.data(using: .utf8),
           let result = try? JSONDecoder().decode(PythonResult.self, from: data) {
            DispatchQueue.main.async {
                self.result = result
                self.modelOutput = output
            }
        }
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
    

    func updatePy() {
        self.modelOutput = "Loading..."
        DispatchQueue.global(qos: .background).async {
            _ = self.getPy()
            
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
    
    var timeRemaining: Double { Double(prediction) }
    var batteryPercent: Int { Int(features["Battery_Percent"] ?? 0) }
    var maximumCapacity: Int { Int(features["Maximum_Capacity"] ?? 0) }
    var cycleCount: Int { Int(features["Cycle_Count"] ?? 0)}
    var condition: String {
        let cond = Int(features["Battery_Condition"] ?? 0)
        switch cond {
        case 0: return "Normal"
        case 1: return "Service Recommended"
        default: return "Battery Condition Unknown"
        }
    }
    
    var totalMemory: Double { Double(features["Total_Memory"] ?? 0)}
    var usedMemory: Double { Double(features["Used_Memory"] ?? 0)}
    
    var numOfProcesses: Int { Int(features["Process_Count"] ?? 0) }
    var processPower: Double{ Double(features["Process_Power"] ?? 0) }
    var processState: Int{ Int(features["Process_State"] ?? 0) }
    
    var CpuUsage: Double { Double(features["CPU_Usage"] ?? 0)}
    var CpuFrequency: Double{ Double(features["old_CPU_Frequency"] ?? 0)}
    var CpuResidency: Double{ Double(features["old_CPU_Residency"] ?? 0)}
    var CpuIdle:Double { Double(features["CPU_Idle"] ?? 0)}
    var CpuPower:Double{ Double(features["old_CPU_Power"] ?? 0) }
    
    var GpuFrequency: Double{ Double(features["Avg_GPU_Frequency"] ?? 0) }
    var GpuResidency: Double{ Double(features["Avg_GPU_Residency"] ?? 0) }
    var GpuIdle:Double { Double(features["Avg_GPU_idle"] ?? 0) }
    var GpuPower:Double{ Double(features["GPU_Power"] ?? 0) }
    var GpuUsage: Double { Double(100 - self.GpuIdle) }

}
