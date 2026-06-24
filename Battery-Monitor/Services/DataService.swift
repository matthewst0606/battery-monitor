//
//  DataService.swift
//  Battery-Monitor
//
//  Created by Matt on 6/16/26.
//

import Foundation

func appDataDirectory() throws -> URL {
    let fileManager = FileManager.default

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
    let destination = try appDataDirectory()
        .appendingPathComponent(fileName)

    guard !fileManager.fileExists(atPath: destination.path)
    else { return destination }


    let fileURL = URL(fileURLWithPath: fileName)
    let resourceName = fileURL
        .deletingPathExtension()
        .lastPathComponent
    
    let bundledFile = Bundle.main.url(
        forResource: resourceName,
        withExtension: fileURL.pathExtension,
        subdirectory: "data"
    ) ?? Bundle.main.url(
        forResource: resourceName,
        withExtension: fileURL.pathExtension
    )

    if let bundledFile {
        try fileManager.copyItem(
            at: bundledFile,
            to: destination
        )
    }
    return destination
}





// format the timestamp for the csv files
func logTimestamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
}

// appends a new row to a given .csv directory
func logToCSV(_ dir: String, _ columns: [String]) {
    do {
        let url = try appDataDirectory(fileName: dir)
        let row = columns
            .joined(separator: ",")
            .appending("\n")
        
        
        if !FileManager.default.fileExists(atPath: url.path) {
            try row.write(
                to: url,
                atomically: true,
                encoding: .utf8
            )
        }
        else if let handle = try? FileHandle(forWritingTo: url) {
            try handle.seekToEnd()
            handle.write(row.data(using: .utf8)!)
            try handle.close()
        }
    }
    catch { print("failed to write to \(dir)!") }
}
