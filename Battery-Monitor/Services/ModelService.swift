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
    
    @Published var modelOutput = ""
    @Published var timeRemaining: Double = 0.0
    @Published var batteryPercent: Int = 0
    @Published var batteryCondition: String = ""
    @Published var maximumCapacity: Int = 0
    @Published var cycleCount: Int = 0
    @Published var totalMemory: Double = 0
    @Published var usedMemory: Double = 0
    @Published var numOfProcesses: Int = 0
    @Published var processPower: Double = 0
    @Published var processState: Int = 0
    @Published var CpuUsage: Double = 0.0
    @Published var CpuFrequency: Double = 0.0
    @Published var CpuResidency: Double = 0.0
    @Published var CpuIdle: Double = 0.0
    @Published var CpuPower: Double = 0.0
    @Published var GpuUsage: Double = 0.0
    @Published var GpuFrequency: Double = 0.0
    @Published var GpuResidency: Double = 0.0
    @Published var GpuIdle: Double = 0.0
    @Published var GpuPower: Double = 0.0

    private var pythonTimer: AnyCancellable?
    private var isRunningPython = false
    
    
    
    
    
    
    struct TimeRemaining: Identifiable {
        let name: String
        let prediction: Double
        let timestamp: Date
        let id = UUID()

        init(name: String, prediction: Double, hour: Int) {
            self.name = name
            self.prediction = prediction
            let calendar = Calendar.autoupdatingCurrent
            self.timestamp = calendar.date(from: DateComponents(hour: hour))!
        }
    }
    @Published var outputHistory: [TimeRemaining] = []
    
    
    init() {
        pythonTimer = Timer.publish(every: 120, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isRunningPython else { return }
                self.isRunningPython = true
                
                DispatchQueue.global(qos: .background).async {
                    _ = self.getPy()
                    DispatchQueue.main.async { self.isRunningPython = false }
                }
            }
    }
    
    
    func getPy() -> String {
        let (process, outputPipe, errorPipe) = makePythonProcess()
        
        do {
            try process.run()
        }
        catch {
            print("Failed to run Python:", error)
        }
        
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
                self.timeRemaining = Double(result.prediction)
                self.outputHistory.append(
                    TimeRemaining (
                        name: "estimatedBattery",
                        prediction: Double(result.prediction),
                        hour: Calendar.current.component(.hour, from: Date())
                    )

                )
                if self.outputHistory.count > 48 { self.outputHistory.removeFirst() }
                
                
                
                
                self.batteryPercent = Int(result.features["Battery_Percent"] ?? 0)
                
                let condition = Int(result.features["Battery_Condition"] ?? 0)
                switch condition {
                case 0: self.batteryCondition = "Normal"
                case 1: self.batteryCondition = "Service Recommended"
                default: self.batteryCondition = "Battery Condition Unknown"
                }
                
                self.maximumCapacity = Int(result.features["Maximum_Capacity"] ?? 0)
                self.totalMemory = Double(result.features["Total_Memory"] ?? 0)
                self.usedMemory = Double(result.features["Used_Memory"] ?? 0)
                self.cycleCount = Int(result.features["Cycle_Count"] ?? 0)
                self.numOfProcesses = Int(result.features["Process_Count"] ?? 0)
                
                self.processPower = Double(result.features["Process_Power"] ?? 0)
                self.processState = Int(result.features["Process_State"] ?? 0)
                
                self.CpuUsage = Double(result.features["CPU_Usage"] ?? 0)
                self.CpuFrequency = Double(result.features["old_CPU_Frequency"] ?? 0)
                self.CpuResidency = Double(result.features["old_CPU_Residency"] ?? 0)
                self.CpuIdle = Double(result.features["CPU_Idle"] ?? 0)
                self.CpuPower = Double(result.features["old_CPU_Power"] ?? 0)

                self.GpuPower = Double(result.features["GPU_Power"] ?? 0)
                self.GpuFrequency = Double(result.features["Avg_GPU_Frequency"] ?? 0)
                self.GpuResidency = Double(result.features["Avg_GPU_Residency"] ?? 0)
                self.GpuIdle = Double(result.features["Avg_GPU_idle"] ?? 0)
                self.GpuUsage = Double(100 - self.GpuIdle)
                
                self.modelOutput = """
                    Prediction: \(result.prediction)
                    Battery: \(Int(result.features["Battery_Percent"] ?? 0))%
                    CPU Usage: \(result.features["CPU_Usage"] ?? 0)%
                """
            }
        }
        return output
    }
    
    struct PythonResult: Codable {
        let features: [String: Double]
        let prediction: Int
    }
    
    private func makePythonProcess() -> (process: Process, outputPipe: Pipe, errorPipe: Pipe) {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        let scriptDir = URL(fileURLWithPath: "/Users/matt/Battery-Monitor/Battery-Monitor/SwiftPy")
        
        process.arguments = [scriptDir.appendingPathComponent("main.py").path]
        process.currentDirectoryURL = scriptDir
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        return (process, outputPipe, errorPipe)
    }
    

    
    
    
    func updatePy() {
        self.modelOutput = "Loading..."
        DispatchQueue.global(qos: .background).async {
            let result = self.getPy()
            DispatchQueue.main.async {
                self.modelOutput = result
            }
        }
    }
}
