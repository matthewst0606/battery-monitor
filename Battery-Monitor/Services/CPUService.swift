//
//  CPUService.swift
//  Battery-Monitor
//
//  Created by Matt on 6/13/26.
//

import MachO
import Foundation
import Combine
import SwiftUI

struct RawCPUInfo {
    let processorCount: UInt32
    let processorInfo: processor_info_array_t?
    let processorInfoCount: mach_msg_type_number_t
}

struct CPUInfo {
    var activeCores: Double
    var user: Double
    var sys: Double
    var idle: Double
    var total: Double
}




class CPUService: ObservableObject {
    @Published var info: CPUInfo?
    private var oldUser: UInt32?
    private var oldSys: UInt32?
    private var oldIdle: UInt32?
    private var activeCores = ProcessInfo.processInfo.activeProcessorCount
    
    private let serviceHelper = ServiceHelper()

    
    init() {
        self.info = getProcessorInfo()
        serviceHelper.createTimer {
            if let newInfo = self.getProcessorInfo() {
                self.info = newInfo
                self.logCPUInfo()
            }
        }
    }
    
    
    func getChipName() -> String {
        var size: size_t = 0

        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var cpu = [CChar](repeating: 0, count: size)

        sysctlbyname("machdep.cpu.brand_string", &cpu, &size, nil, 0)
        return String(cString: cpu)
    }
    
    
    private func logCPUInfo() {
        do {
            let url = try appDataDirectory(fileName: "cpu.csv")
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            
            let timestamp = formatter.string(from: Date())
            let cpuTotal = String(format: "%.2f", info?.total ?? 0)
            let cpuUser = String(format: "%.2f",info?.user ?? 0)
            let cpuSystem = String(format: "%.2f",info?.sys ?? 0)
            let cpuIdle = String(format: "%.2f",info?.idle ?? 0)
            
            let row = "\(timestamp), \(cpuTotal), \(cpuUser), \(cpuSystem), \(cpuIdle)\n"
            
            if !FileManager.default.fileExists(atPath: url.path) {
                try? "timestamp, cpuTotal, cpuUser, cpuSystem, cpuIdle\n"
                    .write(to: url, atomically: true, encoding: .utf8)
            }
            
            if let handle = try? FileHandle(forWritingTo: url) {
                _ = try? handle.seekToEnd()
                handle.write(row.data(using: .utf8)!)
                try? handle.close()
            }
        }
        catch {
            print("failed to write cpu log!")
        }
    }
    
    
    
    
    
    private func GetRawCPUInfo() -> RawCPUInfo? {
        // arguments for host_processor_info
        var processorCount: UInt32 = 0
        var processorInfo: processor_info_array_t?
        var processorInfoCount: mach_msg_type_number_t = 0
    
        // get the CPU load info for every
        // processor/core, and returns a status code
        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &processorCount,
            &processorInfo,
            &processorInfoCount
        )
        
        // return nil if processorInfo is empty
        guard result == KERN_SUCCESS, let _ = processorInfo else { return nil }
        
        return RawCPUInfo (
            processorCount: processorCount,
            processorInfo: processorInfo,
            processorInfoCount: processorInfoCount)
    }
    
    
    
    
    func getProcessorInfo() -> CPUInfo? {
        guard let info = GetRawCPUInfo() else { return nil }
        
        // deallocation of host_processor_info
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: info.processorInfo),
                vm_size_t(info.processorInfoCount * UInt32(MemoryLayout<integer_t>.size)))
        }
        
        var totalUser: UInt32 = 0
        var totalSys: UInt32 = 0
        var totalIdle: UInt32 = 0
        
        return info.processorInfo?.withMemoryRebound(
            to: processor_cpu_load_info.self,
            capacity: Int(info.processorCount)
        ) { ptr -> CPUInfo? in
            
            for i in 0..<Int(info.processorCount) {
                let cpuLoad = ptr[i]
                totalUser += UInt32(cpuLoad.cpu_ticks.0)
                totalSys += UInt32(cpuLoad.cpu_ticks.1)
                totalIdle += UInt32(cpuLoad.cpu_ticks.2)
            }
            
            let total = totalUser + totalSys + totalIdle
            guard total > 0 else { return nil }
            
            guard let oldUser = oldUser,
                  let oldSys = oldSys,
                  let oldIdle = oldIdle
            else {
                self.oldUser = totalUser
                self.oldSys = totalSys
                self.oldIdle = totalIdle
                return nil
            }
            
            
            // calculates the change in cpu details
            let activeDelta = Double((totalUser + totalSys) - (oldUser + oldSys))
            let userDelta = Double((totalUser) - (oldUser))
            let sysDelta = Double((totalSys) - (oldSys))
            let idleDelta = Double((totalIdle) - (oldIdle))
            let totalDelta = Double((totalUser + totalSys + totalIdle) - (oldUser + oldSys + oldIdle))
            
            self.oldUser = totalUser
            self.oldSys = totalSys
            self.oldIdle = totalIdle
            
            let usagePercent = activeDelta / totalDelta * 100
            let userPercent = userDelta / totalDelta * 100
            let sysPercent = sysDelta / totalDelta * 100
            let idlePercent = idleDelta / totalDelta * 100
            
            
            return CPUInfo (
                activeCores: Double(activeCores),
                user: userPercent,
                sys: sysPercent,
                idle:idlePercent,
                total:usagePercent
            )
        }
    }
}
