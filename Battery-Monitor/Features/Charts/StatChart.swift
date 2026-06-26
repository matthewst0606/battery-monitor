//
//  StatChart.swift
//  Battery-Monitor
//
//  Created by Matt on 6/25/26.
//

import SwiftUI

// describes what to chart...
// e.g. time remaining uses battery.csv, is located
// on column 4, and is divided by 60 to display 
// hours instead of minutes
struct StatChart: Equatable {
    let id: String
    let fileName: String
    let valueColumn: Int
    let yAxisLabel: String
    let yAxisDomain: ClosedRange<Double>
    let color: Color
    private let valueTransform: (Double) -> Double

    init(
        id: String,
        fileName: String,
        valueColumn: Int,
        yAxisLabel: String,
        yAxisDomain: ClosedRange<Double>,
        color: Color,
        valueTransform: @escaping (Double) -> Double = { $0 }
    ) {
        self.id = id
        self.fileName = fileName
        self.valueColumn = valueColumn
        self.yAxisLabel = yAxisLabel
        self.yAxisDomain = yAxisDomain
        self.color = color
        self.valueTransform = valueTransform
    }

    // charts are considered the same if they have the same id
    static func == (chartA: StatChart, chartB: StatChart) -> Bool {
        chartA.id == chartB.id
    }


    // applies this chart's value conversion before plotting
    func chartValue(_ value: Double) -> Double {
        valueTransform(value)
    }
}
