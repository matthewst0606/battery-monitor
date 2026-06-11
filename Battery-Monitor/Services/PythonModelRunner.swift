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
    @Published var timeRemaining: Double = 0.0
    private var pythonTimer: AnyCancellable?
    private var isRunningPython = false
    
    
    init() {
        pythonTimer = Timer.publish(every: 25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isRunningPython else { return }
                self.isRunningPython = true
                
                DispatchQueue.global(qos: .background).async {
                    let output = self.getPy()
                    let out = output.trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = Double(out) ?? 0
                    
                    DispatchQueue.main.async {
                        self.timeRemaining = value
                        self.isRunningPython = false
                    }
                }
            }
    }
    
    
    func getPy() -> String {
        let (process, outputPipe, errorPipe) = makePythonProcess()
        
        
        do { try process.run() }
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
        
        if !error.isEmpty {
            print("Python error:", error)
            return error
        }
    
        print("Python output:", output)
        return output
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
}
