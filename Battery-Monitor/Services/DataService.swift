//
//  DataService.swift
//  Battery-Monitor
//
//  Created by Matt on 6/16/26.
//

import Foundation

func appDataDirectory(fileName: String) throws -> URL {
    let serviceFile = URL(fileURLWithPath: #filePath)

    return serviceFile
        .deletingLastPathComponent()      // Services
        .appendingPathComponent("Data")   // Services/Data
        .appendingPathComponent(fileName)
}
