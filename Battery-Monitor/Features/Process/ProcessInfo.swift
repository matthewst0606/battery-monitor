//
//  ProcessInfo.swift
//  Battery-Monitor
//
//  Created by Matt on 6/26/26.
//

struct RunningProcess: Identifiable {
    var id: Int { pid }
    var pid: Int
    var command: String
    var state: String
    var power: String
}
