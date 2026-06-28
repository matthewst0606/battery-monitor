//
//  CPUInfo.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//
import MachO
import SwiftUI

struct CPUInfo {
    var activeCores: Double
    var user: Double
    var sys: Double
    var idle: Double
    var total: Double
}

// -------------------------
// ===== Menu Toggling =====
// -------------------------
struct CPUMenuView: View {
    var body: some View {
        AppStorageToggle("CPU Usage", key: CPUMenuKey.total)
        AppStorageToggle("User Usage", key: CPUMenuKey.user)
        AppStorageToggle("System Usage", key: CPUMenuKey.system)
        AppStorageToggle("System Idle", key: CPUMenuKey.idle)
    }
}

enum CPUMenuKey {
    static let total = "cpu_usage"
    static let user = "user_usage"
    static let system = "system_usage"
    static let idle = "idle_usage"

}
