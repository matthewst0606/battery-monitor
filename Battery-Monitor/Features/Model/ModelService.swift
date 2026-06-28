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
