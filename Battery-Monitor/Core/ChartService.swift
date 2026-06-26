//
//  ChartService.swift
//  Battery-Monitor
//
//  Created by Matt on 6/26/26.
//

import Foundation

struct MetricChartPoint: Identifiable {
    let id = UUID()
    var val: Double
    var time: Date

    init(val: Double, time: Date) {
        self.val = val
        self.time = time
    }
}

// Loads the latest 25 chart points from a CSV column.
func loadChart(_ fileName: String, columnIndex: Int) -> [MetricChartPoint] {
    guard let fileURL = try? appDataDirectory(fileName: fileName)
    else { return [] }
    guard let contents = try? String(contentsOf: fileURL, encoding: .utf8)
    else { return [] }
    
    let rows = contents
        .split(separator: "\n")
        .dropFirst() // skips the header
        .suffix(25)  // use only the latest 25 columns
    
    return rows.compactMap { row -> MetricChartPoint? in
        let cols = row.split(separator: ",")
        guard cols.count > columnIndex,
            let time = parseTimestamp(String(cols[0])),
            let val = Double(String(cols[columnIndex]))
        else { return nil }
        
        return MetricChartPoint(val: val, time: time)
    }
}



// format the timestamp for the charts
func parseTimestamp(_ timestamp: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.date(from: timestamp)
}


