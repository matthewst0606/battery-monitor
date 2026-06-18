//
//  MemoryService.swift
//  Battery-Monitor
//
//  Created by Matt on 6/13/26.
//

import Foundation
import Combine
import MachO
import Darwin



struct MemoryInfo {
    var total: Double
    var used: Double
    var available: Double
    var cached: Double
}

class MemoryService: ObservableObject {
    @Published var info: MemoryInfo?
    private var phyMemory = ProcessInfo.processInfo.physicalMemory
    
    private let serviceHelper = ServiceHelper()

    
    
    init() {
        self.info = getMemoryInfo()
        serviceHelper.createTimer {
            if let newInfo = self.getMemoryInfo() {
                self.info = newInfo
                self.logMemoryInfo()
            }
        }
    }
    
    
    func getMemoryInfo() -> MemoryInfo? {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size /
            MemoryLayout<integer_t>.size
        )

        _ = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    $0,
                    &count
                )
            }
        }
        
                
        let usedBytes = (
            UInt64(stats.internal_page_count) +
            UInt64(stats.compressor_page_count) +
            UInt64(stats.wire_count)
        ) * UInt64(vm_kernel_page_size)
        
        
        let cachedBytes = (
            UInt64(stats.inactive_count) +
            UInt64(stats.speculative_count)
        ) * UInt64(vm_kernel_page_size)
        
        
        let totalGB = Double(phyMemory) / 1024 / 1024 / 1024
        let usedGB = Double(usedBytes) / 1024 / 1024 / 1024
        let cachedGB = Double(cachedBytes) / 1024 / 1024 / 1024
        let availableGB = Double(totalGB - usedGB)
        
        
        return MemoryInfo (
            total: totalGB,
            used: usedGB,
            available: availableGB,
            cached: cachedGB
        )
    }

    
    
    private func logMemoryInfo() {
        do {
            let url = try appDataDirectory(fileName: "memory.csv")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timestamp = formatter.string(from: Date())

            let totalGB = String(format: "%.0f", info?.total ?? 0)
            let usedGB = String(format: "%.2f",info?.used ?? 0)
            let cachedGB = String(format: "%.2f",info?.cached ?? 0)
            let availableGB = String(format: "%.2f",info?.available ?? 0)
            
            let row = "\(timestamp), \(totalGB), \(usedGB), \(cachedGB), \(availableGB)\n"
            
            if !FileManager.default.fileExists(atPath: url.path) {
                try? "timestamp, totalGB, usedGB, cachedGB, availableGB\n"
                    .write(to: url, atomically: true, encoding: .utf8)
            }
            
            if let handle = try? FileHandle(forWritingTo: url) {
                _ = try? handle.seekToEnd()
                handle.write(row.data(using: .utf8)!)
                try? handle.close()
            }
            
        }
        catch {
            print("failed to write memory log!")
        }
    }
}
