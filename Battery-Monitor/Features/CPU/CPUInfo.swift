//
//  CPUInfo.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//
import MachO

struct CPUInfo {
    var activeCores: Double
    var user: Double
    var sys: Double
    var idle: Double
    var total: Double
}
