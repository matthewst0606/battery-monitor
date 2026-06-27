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


class CPUService: ObservableObject {
    @Published var info: CPUInfo?
    private var oldUser: UInt32?
    private var oldSys: UInt32?
    private var oldIdle: UInt32?
    private var activeCores = ProcessInfo.processInfo.activeProcessorCount
    private let timerService = TimerService()

    
    // initializes info, and creates a timer
    init() {
        self.info = getProcessorInfo()
        timerService.createTimer {
            if let newInfo = self.getProcessorInfo() {
                self.info = newInfo
                self.logCPUInfo()
            }
        }
    }
    
    
    /* returns the processors name as a string.The first call
       to sysctlbyname() gets the size of "machdep.cpu.brand_string".
       An array of type CChar (the char type in C) is then
       passed in the second call to sysctlbyname() and
       then returns the actual name of the cpu e.g. M1, M2, ...
    */
    func getChipName() -> String {
        var size: size_t = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        
        var cpu = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &cpu, &size, nil, 0)
        return String(cString: cpu)
    }
    

    /* gets raw CPU load data from macOS (per core).
       host_processor_info writes its results into the
       output variables: processorCount, processorInfo, and
       processorInfoCount
     
       processorInfo points to an arrray of CPU tick counts.
       Returns nil if macOS fails to provide the data
     */
    private func getRawCPUInfo() -> RawCPUInfo? {
        var processorCount: UInt32 = 0
        var processorInfo: processor_info_array_t?
        var processorInfoCount: mach_msg_type_number_t = 0
    
        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &processorCount,
            &processorInfo,
            &processorInfoCount
        )
        
        guard result == KERN_SUCCESS, let _ = processorInfo
        else { return nil }
        
        return RawCPUInfo (
            processorCount: processorCount,
            processorInfo: processorInfo,
            processorInfoCount: processorInfoCount)
    }
    
    
    
    /* calls getRawCPUInfo
     
   
     */
    func getProcessorInfo() -> CPUInfo? {
        guard let info = getRawCPUInfo() else { return nil }
        
        // deallocation of host_processor_info
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: info.processorInfo),
                vm_size_t(info.processorInfoCount * UInt32(MemoryLayout<integer_t>.size))
            )
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
            
            
            // calculates the change in cpu details to update in real time
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
    
    
    
    // appends the new battery info to cpu.csv
    private func logCPUInfo() {
        let values = [
            logCSVTimestamp(),
            String(format: "%.2f", info?.total ?? 0),
            String(format: "%.2f",info?.user ?? 0),
            String(format: "%.2f",info?.sys ?? 0),
            String(format: "%.2f",info?.idle ?? 0),
        ]
        
        logToCSV("cpu.csv", values)
    }
        
}

private struct RawCPUInfo {
    let processorCount: UInt32
    let processorInfo: processor_info_array_t?
    let processorInfoCount: mach_msg_type_number_t
}
