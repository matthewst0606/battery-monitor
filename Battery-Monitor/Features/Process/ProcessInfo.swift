//
//  ProcessInfo.swift
//  Battery-Monitor
//
//  Created by Matt on 6/26/26.
//

struct RunningProcess: Identifiable {
    var id: String { pid }
    var pid: String
    var command: String
    var state: String
    var power: String
}
