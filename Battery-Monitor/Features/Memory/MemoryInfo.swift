//
//  MemoryInfo.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//

import SwiftUI

struct MemoryInfo {
    var total: Double
    var used: Double
    var available: Double
    var cached: Double
}


// -------------------------
// ===== Menu Toggling =====
// -------------------------
struct MemoryMenuView: View {
    var body: some View {
        AppStorageToggle("Total Memory", key: MemoryMenuKey.total)
        AppStorageToggle("Cached Memory", key: MemoryMenuKey.cached)
        AppStorageToggle("Used Memory", key: MemoryMenuKey.used)
        AppStorageToggle("Available Memory", key: MemoryMenuKey.available)
    }
}
enum MemoryMenuKey {
    static let total = "total_memory"
    static let cached = "cached_memory"
    static let used = "used_memory"
    static let available = "available_memory"
}
