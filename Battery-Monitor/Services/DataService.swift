//
//  DataService.swift
//  Battery-Monitor
//
//  Created by Matt on 6/16/26.
//

import Foundation


func appDataDirectory() throws -> URL {
    let fileManager = FileManager.default

#if DEBUG
    // Keep development logs in the project so they are visible in Xcode.
    let projectDataDirectory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // Services
        .deletingLastPathComponent() // Battery-Monitor
        .appendingPathComponent("SwiftPy", isDirectory: true)
        .appendingPathComponent("data", isDirectory: true)

    var isDirectory: ObjCBool = false
    if fileManager.fileExists(
        atPath: projectDataDirectory.path,
        isDirectory: &isDirectory
    ), isDirectory.boolValue {
        return projectDataDirectory
    }
#endif

    // Installed release builds use writable runtime storage.
    let applicationSupport = try fileManager.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    let directory = applicationSupport
        .appendingPathComponent("Battery-Monitor", isDirectory: true)
        .appendingPathComponent("Data", isDirectory: true)

    try fileManager.createDirectory(
        at: directory,
        withIntermediateDirectories: true
    )
    return directory
}

func appDataDirectory(fileName: String) throws -> URL {
    let fileManager = FileManager.default
    let destination = try appDataDirectory().appendingPathComponent(fileName)

    guard !fileManager.fileExists(atPath: destination.path) else {
        return destination
    }


    let fileURL = URL(fileURLWithPath: fileName)
    let resourceName = fileURL.deletingPathExtension().lastPathComponent
    let resourceExtension = fileURL.pathExtension
    let bundledFile = Bundle.main.url(
        forResource: resourceName,
        withExtension: resourceExtension,
        subdirectory: "data"
    ) ?? Bundle.main.url(
        forResource: resourceName,
        withExtension: resourceExtension
    )

    if let bundledFile {
        try fileManager.copyItem(at: bundledFile, to: destination)
    }

    return destination
}
